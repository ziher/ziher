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
    assert inv.unassigned?
    inv.to_clarify!
    assert inv.to_clarify?
  end

  test "claimable scope returns unassigned non-final invoices" do
    inv = KsefInvoice.create!(base_attrs.merge(unit_id: nil, status: :unassigned))
    assert_includes KsefInvoice.claimable, inv
    inv.dismissed!
    assert_not_includes KsefInvoice.claimable, inv
  end

  test "for_user returns claimable + invoices on user units" do
    user = users(:master_1zgm)
    own_unit = units(:troop_1zgm)
    other_unit = units(:troop_2zgm)

    own = KsefInvoice.create!(base_attrs.merge(ksef_number: "X-1", unit_id: own_unit.id, status: :to_clarify))
    pool = KsefInvoice.create!(base_attrs.merge(ksef_number: "X-2", unit_id: nil))
    other = KsefInvoice.create!(base_attrs.merge(ksef_number: "X-3", unit_id: other_unit.id, status: :to_clarify))

    visible = KsefInvoice.for_user(user)
    assert_includes visible, own
    assert_includes visible, pool
    assert_not_includes visible, other
  end

  test "for_user returns only pool invoices when user has no units" do
    user = users(:treasurer_zg)
    assert_empty user.units, "fixture precondition: treasurer_zg should have no units"

    pool = KsefInvoice.create!(base_attrs.merge(ksef_number: "P-1", unit_id: nil))
    assigned = KsefInvoice.create!(base_attrs.merge(ksef_number: "P-2", unit_id: units(:troop_1zgm).id, status: :to_clarify))

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
