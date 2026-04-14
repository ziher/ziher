require 'test_helper'

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
    @category = categories(:one)
  end

  test "should get index" do
    get categories_path
    assert_response :success
  end

  test "index should have selecting years" do
    get categories_path
    years = Category.get_all_years()
    years.each do |year|
      assert_select "select option[value='#{year}']"
    end
  end

  test "selected criteria should stay selected" do
    get categories_path, params: {year: 2012}
    assert_select "select[name='year'] option[selected][value='2012']"
  end

  test "should get new" do
    get new_category_path
    assert_response :success
  end

  test "should create category" do
    assert_difference('Category.count', 1) do
      post categories_url, params: {category: {name: "NewCategory", year: 2014}}
    end

    assert_redirected_to categories_path
  end

  test "should show category" do
    get category_path(@category)
    assert_response :success
  end

  test "should get edit" do
    get edit_category_path(@category)
    assert_response :success
  end

  test "should update category" do
    put category_url(@category), params: {category: {name: "updated"}}
    assert_redirected_to categories_path
  end

  test "should destroy not used category" do
    category = categories(:not_used)

    assert_difference('Category.count', -1) do
      delete category_path(category)
    end

    assert_redirected_to categories_path
  end

  test "should not destroy used category" do
    category = categories(:five)

    assert_difference('Category.count', 0) do
      delete category_path(category)
    end

    assert_redirected_to categories_path
  end

  test "index shows empty-year banner and copy button for a year without categories" do
    empty_year = 2099
    assert_equal 0, Category.where(year: empty_year).count

    get categories_path, params: { year: empty_year }
    assert_response :success
    assert_select "div.alert", text: /Plan kont dla roku/
    assert_select "form[action=?]", copy_from_previous_year_categories_path(year: empty_year)
  end

  test "copy_from_previous_year clones categories into the target year" do
    target_year = 2099
    assert_equal 0, Category.where(year: target_year).count
    source_year = Category.where("year < ?", target_year).maximum(:year)
    expected_count = Category.where(year: source_year).count
    assert expected_count > 0

    assert_difference('Category.where(year: target_year).count', expected_count) do
      post copy_from_previous_year_categories_path, params: { year: target_year }
    end
    assert_redirected_to categories_path(year: target_year)
  end

  test "copy_from_previous_year refuses to overwrite a year that already has categories" do
    target_year = 2012
    assert Category.where(year: target_year).exists?

    assert_no_difference('Category.where(year: target_year).count') do
      post copy_from_previous_year_categories_path, params: { year: target_year }
    end
    assert_redirected_to categories_path(year: target_year)
    assert_match(/już istnieje/, flash[:alert])
  end
end
