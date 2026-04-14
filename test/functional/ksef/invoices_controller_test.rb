require 'test_helper'

class Ksef::InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = users(:master_1zgm)
    @unit = units(:troop_1zgm)
    @other_unit = units(:troop_2zgm)

    @assigned = KsefInvoice.create!(
      ksef_number: "I-1", issue_date: Date.today, synced_at: Time.current,
      unit: @unit, status: :to_clarify, gross_amount: 100, seller_name: "S1"
    )
    @pool = KsefInvoice.create!(
      ksef_number: "I-2", issue_date: Date.today, synced_at: Time.current,
      gross_amount: 50, seller_name: "S2"
    )
    @other = KsefInvoice.create!(
      ksef_number: "I-3", issue_date: Date.today, synced_at: Time.current,
      unit: @other_unit, status: :to_clarify, gross_amount: 75, seller_name: "S3"
    )
  end

  test "index shows visible invoices for member" do
    sign_in @member
    get ksef_invoices_url
    assert_response :success
    assert_match "I-1", @response.body
    assert_match "I-2", @response.body
    assert_no_match(/I-3/, @response.body)
  end

  test "superadmin sees everything" do
    sign_in users(:admin)
    get ksef_invoices_url
    assert_response :success
    assert_match "I-1", @response.body
    assert_match "I-2", @response.body
    assert_match "I-3", @response.body
  end

  test "superadmin can assign an invoice to a unit" do
    sign_in users(:admin)
    patch assign_ksef_invoice_url(@pool), params: {
      ksef_invoice: { unit_id: @unit.id, note: "do wyjasnienia" }
    }
    assert_redirected_to ksef_invoices_url
    @pool.reload
    assert_equal @unit, @pool.unit
    assert @pool.to_clarify?
    assert_equal "do wyjasnienia", @pool.note
  end

  test "superadmin can fetch invoice as PDF" do
    sign_in users(:admin)
    get ksef_invoice_url(@assigned, format: :pdf)
    assert_response :success
    assert_equal "application/pdf", @response.media_type
    assert @response.body.start_with?("%PDF"), "expected PDF signature"
  end

  test "member can import assigned invoice into a journal" do
    journal = Journal.create!(
      unit: @unit, year: Date.today.year,
      journal_type_id: JournalType::FINANCE_TYPE_ID, is_open: true
    )
    category = Category.create!(
      name: "KSeF wydatki", is_expense: true, year: Date.today.year
    )

    sign_in @member
    post import_ksef_invoice_url(@assigned), params: {
      import: { journal_id: journal.id, category_id: category.id }
    }
    assert_redirected_to journal_url(journal)
    @assigned.reload
    assert @assigned.imported?
    assert_not_nil @assigned.imported_entry_id
  end
end
