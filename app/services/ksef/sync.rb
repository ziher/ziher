module Ksef
  class Sync
    DEFAULT_FROM = "2024-01-01T00:00:00Z".freeze

    def self.call(exporter_class: Ksef::Exporter)
      new(exporter_class: exporter_class).call
    end

    def initialize(exporter_class:)
      @setting = KsefSetting.instance
      @exporter_class = exporter_class
    end

    def call
      return unless @setting.configured?
      return if @setting.last_sync_status == "running"

      Rails.logger.tagged("KSeF") do
        started_at = Time.current
        Rails.logger.info("sync.start hwm_before=#{next_date_from}")
        begin
          mark_running
          token = Ksef::Auth.access_token(@setting)
          exporter = @exporter_class.new(@setting, access_token: token)
          result = exporter.run(date_from: next_date_from)

          received = result.invoices.size
          persisted = 0
          ApplicationRecord.transaction do
            result.invoices.each do |xml|
              persisted += 1 if persist_invoice(xml)
            end
            advance_hwm(result)
            mark_success
          end

          Rails.logger.info("sync.success received=#{received} persisted=#{persisted} duration_ms=#{((Time.current - started_at) * 1000).to_i} hwm_after=#{@setting.last_hwm_date}")
        rescue StandardError => e
          Rails.logger.error("sync.error class=#{e.class} message=#{e.message}")
          mark_error(e)
          raise
        end
      end
    end

    private

    def next_date_from
      @setting.last_permanent_storage_date.presence || @setting.last_hwm_date.presence || DEFAULT_FROM
    end

    def persist_invoice(xml)
      attrs = Ksef::Parser.parse(xml)
      ksef_number = derive_ksef_number(attrs, xml)
      return false if KsefInvoice.exists?(ksef_number: ksef_number)

      KsefInvoice.create!(attrs.merge(
        ksef_number: ksef_number,
        invoice_xml: xml,
        synced_at: Time.current,
        status: :unassigned
      ))
      true
    end

    def derive_ksef_number(attrs, xml)
      doc = Nokogiri::XML(xml)
      doc.at_xpath("//f:KsefReferenceNumber", Ksef::Parser::NS)&.text.presence ||
        "#{attrs[:seller_nip]}-#{attrs[:invoice_number]}"
    end

    def advance_hwm(result)
      if result.truncated && result.last_permanent_storage_date.present?
        @setting.last_permanent_storage_date = result.last_permanent_storage_date
      else
        @setting.last_hwm_date = result.hwm_date if result.hwm_date.present?
        @setting.last_permanent_storage_date = nil
      end
      @setting.save!
    end

    def mark_running
      @setting.update!(last_sync_status: "running")
    end

    def mark_success
      @setting.update!(last_sync_status: "success", last_sync_at: Time.current, last_sync_error: nil)
    end

    def mark_error(error)
      @setting.update!(last_sync_status: "error", last_sync_at: Time.current, last_sync_error: "#{error.class}: #{error.message}")
    end
  end
end
