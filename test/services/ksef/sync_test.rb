require 'test_helper'
require 'minitest/mock'

class Ksef::SyncTest < ActiveSupport::TestCase
  def setup
    @setting = KsefSetting.instance
    @setting.update!(
      nip: "1234567890",
      api_url: "https://api.example",
      cert_pem: "PEM",
      key_pem:  "KEY",
      last_hwm_date: "2026-01-01T00:00:00Z"
    )
    KsefInvoice.delete_all
  end

  def fake_exporter(result)
    Class.new do
      @result = result
      class << self; attr_accessor :_result; end
      self._result = result
      def initialize(_setting, access_token:); end
      def run(date_from:); self.class._result; end
    end.tap { |k| k._result = result }
  end

  test "persists new invoices, dedupes by ksef_number, updates HWM" do
    sample_xml = File.read(Rails.root.join("test/fixtures/files/ksef/sample_fa3.xml"))
    fake_result = Ksef::Exporter::Result.new(
      invoices: [sample_xml, sample_xml], # duplicate to verify dedup
      hwm_date: "2026-04-14T10:00:00Z",
      truncated: false,
      last_permanent_storage_date: nil
    )

    Ksef::Auth.stub(:access_token, "TOKEN") do
      Ksef::Sync.call(exporter_class: fake_exporter(fake_result))
    end

    assert_equal 1, KsefInvoice.count
    invoice = KsefInvoice.first
    assert_equal "FV/2026/03/0123", invoice.invoice_number

    @setting.reload
    assert_equal "2026-04-14T10:00:00Z", @setting.last_hwm_date
    assert_equal "success", @setting.last_sync_status
  end

  test "is a no-op when setting is not configured" do
    @setting.update!(nip: nil)
    assert_nothing_raised { Ksef::Sync.call }
    assert_equal 0, KsefInvoice.count
  end

  test "records error in last_sync_error on exporter failure" do
    error_exporter = Class.new do
      def initialize(_setting, access_token:); end
      def run(date_from:); raise Ksef::Client::Error, "boom"; end
    end

    Ksef::Auth.stub(:access_token, "TOKEN") do
      assert_raises(Ksef::Client::Error) { Ksef::Sync.call(exporter_class: error_exporter) }
    end

    @setting.reload
    assert_equal "error", @setting.last_sync_status
    assert_match(/boom/, @setting.last_sync_error.to_s)
  end
end
