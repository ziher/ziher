require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should return name" do
    # given
    user = users(:admin)
    user.first_name = "John"
    user.last_name = "Doe"

    # when
    name = user.first_name + " " + user.last_name

    # then
    assert_equal(user.name, name)
  end

  test "should not throw exception when first or last name are empty" do
    # given
    user = users(:admin)
    user.first_name = ""
    user.last_name = ""

    # then
    assert_nothing_raised do
      name = user.name
    end
  end
end
