require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  fixtures :categories

  test "should count all years" do
    assert_equal 3, Category.get_all_years().count
  end

  test "should sort all years" do
    assert_equal [2012, 2013, 2014], Category.get_all_years()
  end

  test "should find categories for year and type" do
    actual = Category.find_by_year_and_type(2012, true)
    expected = [categories(:six), categories(:five)]
    assert_equal expected, actual
  end
end
