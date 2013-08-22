require 'test_helper'

class UnitTest < ActiveSupport::TestCase
  test "find by user" do
    units = Unit.find_by_user(users(:scoutmaster_dukt))
    assert units.count == 1
  end
end
