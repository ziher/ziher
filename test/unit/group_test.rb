require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test "tests up to date with yml" do
    assert_equal(8, Group.all.count)
    
    assert_equal(2, groups(:district_zg_m).units.count)
  end
  
  test "find by user" do
    assert_equal(1, Group.find_by_user(users(:master_zg_m)).count)
    assert_equal(1, Group.find_by_user(users(:master_zg_m), { :can_view_entries => true }).count)
    assert_equal(0, Group.find_by_user(users(:master_zg_m), { :can_manage_entries => true }).count)
    assert_equal(0, Group.find_by_user(users(:master_zg_m), { :can_manage_units => true }).count)
    
    assert_equal(3, Group.find_by_user(users(:master_p_m)).count)
    
    assert_equal(7, Group.find_by_user(users(:master_p)).count)
    
    assert_equal(7, Group.find_by_user(users(:treasurer_p)).count)
    assert_equal(7, Group.find_by_user(users(:treasurer_p), { :can_manage_units => true }).count)
  end
end
