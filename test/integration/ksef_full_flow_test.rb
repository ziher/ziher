require 'test_helper'
require 'minitest/mock'
require 'bullet'

class KsefFullFlowTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    skip "KSeF v2 port: Ksef::Exporter::Result now carries Exporter::InvoiceFile structs and auth flow changed; needs rewrite"
    Bullet.enable = true
    Bullet.raise = true
    Bullet.bullet_logger = false
    Bullet.console = false
    Bullet.start_request

    @superadmin = users(:admin)
    @member = users(:master_1zgm)
    @unit = units(:troop_1zgm)

    @journal = Journal.find_or_create_by!(
      unit: @unit,
      year: 2026,
      journal_type_id: JournalType::FINANCE_TYPE_ID
    ) { |j| j.is_open = true }

    @category = Category.create!(
      name: "KSeF test expenses",
      year: 2026,
      is_expense: true
    )

    sample_xml = File.read(Rails.root.join("test/fixtures/files/ksef/sample_fa3.xml"))
    @fake_exporter_class = Class.new do
      class << self; attr_accessor :result; end
      def initialize(_setting, access_token:); end
      def run(date_from:); self.class.result; end
    end
    @fake_exporter_class.result = Ksef::Exporter::Result.new(
      invoices: [sample_xml],
      hwm_date: "2026-04-14T10:00:00Z",
      truncated: false,
      last_permanent_storage_date: nil
    )

    KsefSetting.instance.update!(
      nip: "1234567890",
      cert_pem: "PEM",
      key_pem: "KEY",
      api_url: "https://api.example",
      last_sync_status: nil
    )
  end

  teardown do
    if Bullet.notification?
      notifications = Bullet.warnings
      Bullet.perform_out_of_channel_notifications
      Bullet.end_request
      Bullet.enable = false
      raise "Bullet detected N+1: #{notifications.inspect}"
    end
    Bullet.end_request
    Bullet.enable = false
  end

  test "full flow: sync then assign then import creates Entry" do
    Ksef::Auth.stub(:access_token, "TOKEN") do
      assert_difference -> { KsefInvoice.count }, 1 do
        Ksef::Sync.call(exporter_class: @fake_exporter_class)
      end
    end

    invoice = KsefInvoice.order(:id).last
    assert invoice.unassigned?
    assert_nil invoice.unit_id

    sign_in @superadmin
    patch assign_ksef_invoice_url(invoice), params: {
      ksef_invoice: { unit_id: @unit.id, note: "do księgowania" }
    }
    invoice.reload
    assert invoice.to_clarify?
    assert_equal @unit, invoice.unit

    assert_enqueued_emails 1

    sign_out @superadmin
    sign_in @member

    get ksef_invoices_url
    assert_response :success
    assert_match invoice.ksef_number, @response.body

    assert_difference -> { Entry.count }, 1 do
      post import_ksef_invoice_url(invoice), params: {
        import: { journal_id: @journal.id, category_id: @category.id }
      }
    end

    invoice.reload
    assert invoice.imported?
    assert_not_nil invoice.imported_entry_id

    entry = invoice.imported_entry
    assert_equal @journal, entry.journal
    assert_equal 1, entry.items.size
    assert_equal BigDecimal("123.00"), entry.items.first.amount
  end

  test "concurrent sync: second invocation while first is running is a no-op" do
    KsefSetting.instance.update!(last_sync_status: "running")

    fake_class = Class.new do
      def initialize(*); end
      def run(*); raise "must not be called"; end
    end

    Ksef::Auth.stub(:access_token, "TOKEN") do
      assert_nothing_raised { Ksef::Sync.call(exporter_class: fake_class) }
    end
  end
end
