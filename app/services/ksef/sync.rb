module Ksef
  class Sync
    # KSeF limits dateRange to max 3 months. Default to 3 months back + 1 day
    # to sit safely inside the window; clamp stale HWM to the same floor.
    def self.default_from_date
      (3.months.ago + 1.day).utc.beginning_of_day.iso8601
    end

    MAX_RANGE = 3.months - 1.day

    def self.call(exporter_class: Ksef::Exporter)
      new(exporter_class: exporter_class).call
    end

    def self.call_for_range(date_from:, date_to:, exporter_class: Ksef::Exporter)
      new(exporter_class: exporter_class, range_from: date_from, range_to: date_to).call
    end

    def initialize(exporter_class:, range_from: nil, range_to: nil)
      @setting      = KsefSetting.instance
      @exporter_class = exporter_class
      @range_from   = range_from
      @range_to     = range_to
    end

    STALE_RUNNING_THRESHOLD = 30.minutes

    def call
      return unless @setting.configured?

      if @setting.last_sync_status == "running"
        if @setting.running_since_at.present? && @setting.running_since_at < STALE_RUNNING_THRESHOLD.ago
          Rails.logger.warn("KSeF sync appears stuck (running since #{@setting.running_since_at}), treating as stale and proceeding")
        else
          return
        end
      end

      Rails.logger.tagged("KSeF") do
        started_at = Time.current
        from = range_sync? ? @range_from.iso8601 : next_date_from
        to   = range_sync? ? @range_to.iso8601   : nil
        Rails.logger.info("sync.start mode=#{range_sync? ? 'range' : 'incremental'} from=#{from} to=#{to || 'hwm'}")

        begin
          mark_running
          token    = Ksef::Auth.access_token(@setting)
          exporter = @exporter_class.new(@setting, access_token: token)
          result   = exporter.run(date_from: from, date_to: to)

          received  = result.invoices.size
          persisted = 0
          ApplicationRecord.transaction do
            result.invoices.each do |file|
              persisted += 1 if persist_invoice(file)
            end
            advance_hwm(result) unless range_sync?
            mark_success
          end

          Rails.logger.info("sync.success mode=#{range_sync? ? 'range' : 'incremental'} received=#{received} persisted=#{persisted} duration_ms=#{((Time.current - started_at) * 1000).to_i}")
        rescue StandardError => e
          Rails.logger.error("sync.error class=#{e.class} message=#{e.message}")
          mark_error(e)
          raise
        end
      end
    end

    private

    def range_sync?
      @range_from.present?
    end

    def next_date_from
      stored = @setting.last_permanent_storage_date.presence || @setting.last_hwm_date.presence
      floor = self.class.default_from_date
      return floor if stored.nil?
      Time.parse(stored) < Time.parse(floor) ? floor : stored
    rescue ArgumentError
      self.class.default_from_date
    end

    def persist_invoice(file)
      return false if KsefInvoice.exists?(ksef_number: file.ksef_number)

      document = Ksef::Parser.parse(file.xml)
      KsefInvoice.create!(Ksef::Parser.persistence_attrs(document).merge(
        ksef_number: file.ksef_number,
        invoice_xml: file.xml,
        synced_at: Time.current,
        status: :pending
      ))
      true
    end

    def advance_hwm(result)
      if result.truncated
        if result.last_permanent_storage_date.blank?
          raise Ksef::Client::Error.new("KSeF returned truncated=true without lastPermanentStorageDate")
        end
        @setting.last_permanent_storage_date = result.last_permanent_storage_date
      else
        @setting.last_hwm_date = result.hwm_date if result.hwm_date.present?
        @setting.last_permanent_storage_date = nil
      end
      @setting.save!
    end

    def mark_running
      @setting.update!(last_sync_status: "running", running_since_at: Time.current)
    end

    def mark_success
      @setting.update!(last_sync_status: "success", last_sync_at: Time.current, last_sync_error: nil, running_since_at: nil)
    end

    def mark_error(error)
      @setting.update!(last_sync_status: "error", last_sync_at: Time.current, last_sync_error: "#{error.class}: #{error.message}", running_since_at: nil)
    end
  end
end
