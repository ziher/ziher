require 'test_helper'

class InventoryEntryTest < ActiveSupport::TestCase

  # TODO: should not use inactive source
  # TODO: should check if finance or bank source is active in entry year

  test "should normalize total value" do
    #given
    entry = inventory_entries(:one)
    entry.total_value = "1 234,56"

    #when
    entry.save!

    #then
    assert_equal(entry.total_value, 1234.56)
  end

end
