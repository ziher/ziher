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
    expected = Category.where(year: 2012, is_expense: true)
    assert_equal expected, actual
  end

  test "should not allow editing category if there are items" do
    # TODO: ten test (i jego rozwiazanie w modelu) trzeba zaimplementowac
    assert true
  end

  test "should not allow multiple one percent categories in a year" do
    #given
    category1 = categories(:one_one_percent)
    category2 = Category.new(:year => category1.year)

    #when
    category2.is_one_percent = true

    #then
    assert_raise(ActiveRecord::RecordInvalid){
      category2.save!
    }
  end
end
