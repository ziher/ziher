require 'test_helper'

class KsefInvoiceTest < ActiveSupport::TestCase
  def base_attrs
    {
      ksef_number: "1111111111-20260101-AB",
      issue_date: Date.new(2026, 1, 1),
      gross_amount: 123.45,
      synced_at: Time.current,
    }
  end

  test "is valid with required attributes" do
    assert KsefInvoice.new(base_attrs).valid?
  end

  test "ksef_number must be unique" do
    KsefInvoice.create!(base_attrs)
    dup = KsefInvoice.new(base_attrs)
    assert_not dup.valid?
    assert dup.errors[:ksef_number].any?, "expected ksef_number to have errors"
  end

  test "status enum exposes symbolic accessors" do
    inv = KsefInvoice.create!(base_attrs)
    assert inv.pending?
    inv.unassigned!
    assert inv.unassigned?
    inv.assigned!
    assert inv.assigned?
  end

  test "status_label returns Polish label" do
    inv = KsefInvoice.new(base_attrs.merge(status: :pending))
    assert_equal "nowa", inv.status_label
    inv.status = :unassigned
    assert_equal "nieprzypisana", inv.status_label
    inv.status = :assigned
    assert_equal "przypisana", inv.status_label
  end

  test "claimable scope returns pool invoices in unassigned status" do
    inv = KsefInvoice.create!(base_attrs.merge(unit_id: nil, status: :unassigned))
    assert_includes KsefInvoice.claimable, inv
    inv.pending!
    assert_not_includes KsefInvoice.claimable, inv
  end

  test "releasable? true for pending and assigned" do
    inv = KsefInvoice.new(base_attrs.merge(status: :pending))
    assert inv.releasable?
    inv.status = :assigned
    assert inv.releasable?
    inv.status = :unassigned
    assert_not inv.releasable?
    inv.status = :imported
    assert_not inv.releasable?
  end

  test "for_user returns pool + invoices on user units" do
    user = users(:master_1zgm)
    own_unit = units(:troop_1zgm)
    other_unit = units(:troop_2zgm)

    own = KsefInvoice.create!(base_attrs.merge(ksef_number: "X-1", unit_id: own_unit.id, status: :assigned))
    pool = KsefInvoice.create!(base_attrs.merge(ksef_number: "X-2", unit_id: nil, status: :unassigned))
    other = KsefInvoice.create!(base_attrs.merge(ksef_number: "X-3", unit_id: other_unit.id, status: :assigned))
    brand_new = KsefInvoice.create!(base_attrs.merge(ksef_number: "X-4", unit_id: nil, status: :pending))

    visible = KsefInvoice.for_user(user)
    assert_includes visible, own
    assert_includes visible, pool
    assert_not_includes visible, other
    assert_not_includes visible, brand_new, "pending invoices should be hidden from regular users"
  end

  test "for_user returns only pool invoices when user has no units" do
    user = users(:treasurer_zg)
    assert_empty user.units, "fixture precondition: treasurer_zg should have no units"

    pool = KsefInvoice.create!(base_attrs.merge(ksef_number: "P-1", unit_id: nil, status: :unassigned))
    assigned = KsefInvoice.create!(base_attrs.merge(ksef_number: "P-2", unit_id: units(:troop_1zgm).id, status: :assigned))

    visible = KsefInvoice.for_user(user)
    assert_includes visible, pool
    assert_not_includes visible, assigned
  end

  test "for_user returns all invoices for superadmin" do
    admin = users(:admin)
    assert admin.is_superadmin

    inv = KsefInvoice.create!(base_attrs.merge(ksef_number: "ADMIN-1", unit_id: units(:troop_1zgm).id, status: :imported))
    assert_includes KsefInvoice.for_user(admin), inv
  end
end
