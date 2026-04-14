require 'test_helper'

class AbilityKsefTest < ActiveSupport::TestCase
  setup do
    @superadmin = users(:admin)
    @member = users(:master_1zgm)
    @member_unit = units(:troop_1zgm)
    @other_unit = units(:troop_2zgm)
  end

  def base_attrs(overrides = {})
    {
      ksef_number: "ABT-#{SecureRandom.hex(4)}",
      issue_date: Date.new(2026, 1, 1),
      synced_at: Time.current
    }.merge(overrides)
  end

  test "superadmin can manage KsefInvoice and KsefSetting" do
    ability = Ability.new(@superadmin)
    assert ability.can?(:manage, KsefInvoice)
    assert ability.can?(:manage, KsefSetting.instance)
  end

  test "member cannot update KsefSetting" do
    ability = Ability.new(@member)
    assert_not ability.can?(:update, KsefSetting.instance)
  end

  test "member can read invoices unassigned or for their unit, not other units" do
    ability = Ability.new(@member)

    own = KsefInvoice.create!(base_attrs(unit: @member_unit, status: :assigned))
    pool = KsefInvoice.create!(base_attrs(unit_id: nil, status: :unassigned))
    other = KsefInvoice.create!(base_attrs(unit: @other_unit, status: :assigned))

    assert ability.can?(:read, own)
    assert ability.can?(:read, pool)
    assert_not ability.can?(:read, other)
  end

  test "member can import an invoice belonging to a unit they manage (assignable)" do
    ability = Ability.new(@member)
    invoice = KsefInvoice.create!(base_attrs(unit: @member_unit, status: :assigned))
    assert ability.can?(:import, invoice)
  end

  test "member cannot import an invoice already imported" do
    ability = Ability.new(@member)
    invoice = KsefInvoice.create!(base_attrs(unit: @member_unit, status: :imported))
    assert_not ability.can?(:import, invoice)
  end

  test "member cannot import an invoice for a unit they do not manage" do
    ability = Ability.new(@member)
    invoice = KsefInvoice.create!(base_attrs(unit: @other_unit, status: :assigned))
    assert_not ability.can?(:import, invoice)
  end

  test "member can claim a pool invoice" do
    ability = Ability.new(@member)
    invoice = KsefInvoice.create!(base_attrs(unit_id: nil, status: :unassigned))
    assert ability.can?(:assign, invoice)
  end

  test "member cannot claim a pending invoice" do
    ability = Ability.new(@member)
    invoice = KsefInvoice.create!(base_attrs(unit_id: nil, status: :pending))
    assert_not ability.can?(:assign, invoice)
  end

  test "member can release an invoice assigned to their manageable unit" do
    ability = Ability.new(@member)
    invoice = KsefInvoice.create!(base_attrs(unit: @member_unit, status: :assigned))
    assert ability.can?(:release, invoice)
  end

  test "member cannot release an invoice for another unit" do
    ability = Ability.new(@member)
    invoice = KsefInvoice.create!(base_attrs(unit: @other_unit, status: :assigned))
    assert_not ability.can?(:release, invoice)
  end

  test "member cannot release an imported invoice" do
    ability = Ability.new(@member)
    invoice = KsefInvoice.create!(base_attrs(unit: @member_unit, status: :imported))
    assert_not ability.can?(:release, invoice)
  end
end
