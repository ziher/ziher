require 'test_helper'

class KsefMailerTest < ActionMailer::TestCase
  setup do
    @unit = units(:troop_1zgm)
    @manager = users(:master_1zgm)
    @invoice = KsefInvoice.create!(
      ksef_number: "M-PUSH-1",
      invoice_number: "FV/2026/001",
      issue_date: Date.today,
      synced_at: Time.current,
      seller_name: "Sprzedawca sp. z o.o.",
      gross_amount: 123.45,
      unit: @unit,
      status: :to_clarify,
      note: "Do weryfikacji"
    )
  end

  test "invoice_assigned delivers to unit managers" do
    msg = KsefMailer.invoice_assigned(@invoice).deliver_now
    assert_includes msg.to, @manager.email
    assert_match @invoice.ksef_number, msg.body.encoded
    assert_match @invoice.seller_name, msg.body.encoded
  end

  test "invoice_assigned subject includes invoice number" do
    msg = KsefMailer.invoice_assigned(@invoice).deliver_now
    assert_match @invoice.invoice_number, msg.subject
  end

  test "invoice_assigned returns null mail when no managers" do
    orphan_unit = units(:troop_2dwf)
    orphan_unit.user_unit_associations.destroy_all
    @invoice.update!(unit: orphan_unit)

    assert_no_emails do
      KsefMailer.invoice_assigned(@invoice).deliver_now
    end
  end
end
