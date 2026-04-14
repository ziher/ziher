require 'test_helper'
require 'minitest/mock'

class KsefFullFlowTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper
  include Devise::Test::IntegrationHelpers

  setup do
    @superadmin = users(:admin)
    @member     = users(:master_1zgm)
    @unit       = units(:troop_1zgm)

    @journal = Journal.find_or_create_by!(
      unit: @unit,
      year: 2026,
      journal_type_id: JournalType::FINANCE_TYPE_ID
    ) { |j| j.is_open = true }

    @category = Category.find_or_create_by!(
      name:       "KSeF test expenses",
      year:       2026,
      is_expense: true
    )

    sample_xml = File.read(Rails.root.join("test/fixtures/files/ksef/sample_fa3.xml"))
    ksef_number = "KSeF-IT-#{SecureRandom.hex(4)}"

    @fake_exporter_class = Class.new do
      class << self; attr_accessor :result; end
      def initialize(_setting, access_token:); end
      def run(date_from:, **); self.class.result; end
    end
    @fake_exporter_class.result = Ksef::Exporter::Result.new(
      invoices:                    [Ksef::Exporter::InvoiceFile.new(ksef_number: ksef_number, xml: sample_xml)],
      hwm_date:                    "2026-04-14T10:00:00Z",
      truncated:                   false,
      last_permanent_storage_date: nil
    )

    KsefSetting.instance.update!(
      nip:             "1234567890",
      cert_pem:        "PEM",
      key_pem:         "KEY",
      api_url:         "https://api.example",
      last_sync_status: nil,
      running_since_at: nil
    )
  end

  test "full flow: sync → assign → import creates Entry" do
    # 1. Sync persists the invoice
    Ksef::Auth.stub(:access_token, "TOKEN") do
      assert_difference -> { KsefInvoice.count }, 1 do
        Ksef::Sync.call(exporter_class: @fake_exporter_class)
      end
    end

    invoice = KsefInvoice.order(:id).last
    assert invoice.pending?, "expected pending after sync, got #{invoice.status}"
    assert_nil invoice.unit_id

    KsefSetting.instance.reload
    assert_equal "success", KsefSetting.instance.last_sync_status
    assert_nil KsefSetting.instance.running_since_at

    # 2. Superadmin assigns to unit
    sign_in @superadmin
    assert_emails 1 do
      patch assign_ksef_invoice_url(invoice), params: {
        ksef_invoice: { unit_id: @unit.id, note: "do księgowania" }
      }
    end
    assert_redirected_to ksef_invoices_path
    invoice.reload
    assert invoice.assigned?, "expected assigned after assign, got #{invoice.status}"
    assert_equal @unit, invoice.unit
    sign_out @superadmin

    # 3. Unit member sees the invoice and imports it
    sign_in @member
    get ksef_invoices_url
    assert_response :success

    assert_difference -> { Entry.count }, 1 do
      post import_ksef_invoice_url(invoice), params: {
        import: {
          journal_id:  @journal.id,
          description: "Test import",
          lines: {
            "0" => { category_id: @category.id, amount: "123.00" }
          }
        }
      }
    end
    assert_redirected_to journal_path(@journal)

    invoice.reload
    assert invoice.imported?, "expected imported after import, got #{invoice.status}"
    assert_not_nil invoice.imported_entry_id

    entry = invoice.imported_entry
    assert_equal @journal,          entry.journal
    assert_equal "Test import",     entry.name
    assert_equal 1,                 entry.items.size
    assert_in_delta 123.00,         entry.items.first.amount.to_f, 0.001
    assert_equal @category,         entry.items.first.category

    sign_out @member
  end

  test "concurrent sync: second invocation while first is running is a no-op" do
    KsefSetting.instance.update!(last_sync_status: "running", running_since_at: 5.minutes.ago)

    boom_class = Class.new do
      def initialize(*); end
      def run(*); raise "must not be called"; end
    end

    assert_nothing_raised { Ksef::Sync.call(exporter_class: boom_class) }
    assert_equal "running", KsefSetting.instance.reload.last_sync_status
  end

  test "stale running sync is overridden and re-runs" do
    KsefSetting.instance.update!(last_sync_status: "running", running_since_at: 1.hour.ago)

    Ksef::Auth.stub(:access_token, "TOKEN") do
      assert_nothing_raised { Ksef::Sync.call(exporter_class: @fake_exporter_class) }
    end

    assert_equal "success", KsefSetting.instance.reload.last_sync_status
  end

  test "double-submit import is rejected for second request" do
    Ksef::Auth.stub(:access_token, "TOKEN") do
      Ksef::Sync.call(exporter_class: @fake_exporter_class)
    end

    invoice = KsefInvoice.order(:id).last
    invoice.update!(unit: @unit, status: :assigned, assigned_by: @superadmin, assigned_at: Time.current)

    sign_in @member

    post import_ksef_invoice_url(invoice), params: {
      import: {
        journal_id: @journal.id,
        lines: { "0" => { category_id: @category.id, amount: "123.00" } }
      }
    }
    assert_redirected_to journal_path(@journal)

    # Simulate second submit — invoice is now imported, CanCan rejects (assignable? = false)
    invoice.reload
    assert invoice.imported?

    assert_no_difference -> { Entry.count } do
      post import_ksef_invoice_url(invoice), params: {
        import: {
          journal_id: @journal.id,
          lines: { "0" => { category_id: @category.id, amount: "123.00" } }
        }
      }
    end
    assert_response :redirect  # CanCan redirects to root with access denied

    sign_out @member
  end
end
