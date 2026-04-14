require 'test_helper'

class Ksef::InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = users(:master_1zgm)
    @unit = units(:troop_1zgm)
    @other_unit = units(:troop_2zgm)

    @assigned = KsefInvoice.create!(
      ksef_number: "I-1", issue_date: Date.today, synced_at: Time.current,
      unit: @unit, status: :assigned, gross_amount: 100, seller_name: "S1"
    )
    @pool = KsefInvoice.create!(
      ksef_number: "I-2", issue_date: Date.today, synced_at: Time.current,
      status: :unassigned, gross_amount: 50, seller_name: "S2"
    )
    @other = KsefInvoice.create!(
      ksef_number: "I-3", issue_date: Date.today, synced_at: Time.current,
      unit: @other_unit, status: :assigned, gross_amount: 75, seller_name: "S3"
    )
    @new_one = KsefInvoice.create!(
      ksef_number: "I-4", issue_date: Date.today, synced_at: Time.current,
      status: :pending, gross_amount: 200, seller_name: "S4"
    )
  end

  test "member default tab is unassigned pool" do
    sign_in @member
    get ksef_invoices_url
    assert_response :success
    assert_match "I-2", @response.body
    assert_no_match(/I-1/, @response.body)
    assert_no_match(/I-3/, @response.body)
    assert_no_match(/I-4/, @response.body)
  end

  test "member can view their assigned tab" do
    sign_in @member
    get ksef_invoices_url(status: "assigned")
    assert_response :success
    assert_match "I-1", @response.body
    assert_no_match(/I-2/, @response.body)
    assert_no_match(/I-3/, @response.body)
    assert_no_match(/I-4/, @response.body)
  end

  test "superadmin default tab is pending when there are pending invoices" do
    sign_in users(:admin)
    get ksef_invoices_url
    assert_response :success
    assert_match "I-4", @response.body
    assert_no_match(/I-1/, @response.body)
  end

  test "superadmin can view each status tab" do
    admin = users(:admin)
    sign_in admin

    get ksef_invoices_url(status: "unassigned")
    assert_match "I-2", @response.body

    get ksef_invoices_url(status: "assigned")
    assert_match "I-1", @response.body
    assert_match "I-3", @response.body

    get ksef_invoices_url(status: "pending")
    assert_match "I-4", @response.body
  end

  test "superadmin can assign an invoice to a unit" do
    sign_in users(:admin)
    patch assign_ksef_invoice_url(@pool), params: {
      ksef_invoice: { unit_id: @unit.id, note: "do wyjasnienia" }
    }
    assert_redirected_to ksef_invoices_url
    @pool.reload
    assert_equal @unit, @pool.unit
    assert @pool.assigned?
    assert_equal "do wyjasnienia", @pool.note
  end

  test "superadmin can release a pending invoice to the pool" do
    sign_in users(:admin)
    patch release_ksef_invoice_url(@new_one)
    assert_redirected_to ksef_invoices_url
    @new_one.reload
    assert @new_one.unassigned?
  end

  test "member can claim a pool invoice to one of their units" do
    sign_in @member
    patch assign_ksef_invoice_url(@pool), params: {
      ksef_invoice: { unit_id: @unit.id, note: "biorę" }
    }
    assert_redirected_to ksef_invoices_url
    @pool.reload
    assert_equal @unit, @pool.unit
    assert @pool.assigned?
    assert_equal @member, @pool.assigned_by
  end

  test "member cannot claim a pool invoice to a unit they do not manage" do
    sign_in @member
    patch assign_ksef_invoice_url(@pool), params: {
      ksef_invoice: { unit_id: @other_unit.id }
    }
    assert_redirected_to ksef_invoice_url(@pool)
    @pool.reload
    assert @pool.unassigned?
    assert_nil @pool.unit_id
  end

  test "member can release an invoice assigned to their unit" do
    sign_in @member
    patch release_ksef_invoice_url(@assigned)
    assert_redirected_to ksef_invoices_url
    @assigned.reload
    assert @assigned.unassigned?
    assert_nil @assigned.unit_id
    assert_nil @assigned.assigned_by_id
  end

  test "member cannot release an invoice for another unit" do
    sign_in @member
    patch release_ksef_invoice_url(@other)
    assert_redirected_to root_url
    @other.reload
    assert @other.assigned?
    assert_equal @other_unit, @other.unit
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
      import: {
        journal_id: journal.id,
        lines: { "0" => { category_id: category.id, amount: "100.00" } }
      }
    }
    assert_redirected_to journal_url(journal)
    @assigned.reload
    assert @assigned.imported?
    assert_not_nil @assigned.imported_entry_id
  end
end
