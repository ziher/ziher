require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  fixtures :categories

  test "should count all years" do
    years = []
    Category.all.each do |category|
      years << category.year
    end

    assert_equal years.uniq.count, Category.get_all_years().count
  end

  test "should sort all years" do
    years = Category.get_all_years()

    years.each_with_index do |year, index|
      if index+1 < years.count
        next_year = years[index+1]
        assert year < next_year
      end
    end
  end

  test "should find categories for year and type" do
    actual = Category.find_by_year_and_type(2012, true)
    expected = Category.find(:all, :conditions => {:year => 2012, :is_expense => true})
    assert_equal expected, actual
  end
end
