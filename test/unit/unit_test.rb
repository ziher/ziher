require 'test_helper'

class UnitTest < ActiveSupport::TestCase
  test "find by user" do
    units = Unit.find_by_user(users(:admin))
    assert_equal(Unit.all.count, units.count)

    units = Unit.find_by_user(users(:scoutmaster_dukt))
    assert_equal(1, units.count)

    units = Unit.find_by_user(users(:master_zg_m))
    assert_equal(2, units.count)

    units = Unit.find_by_user(users(:master_p_f))
    assert_equal(4, units.count)
    
    units = Unit.find_by_user(users(:master_p))
    assert_equal(8, units.count)
  end
end
