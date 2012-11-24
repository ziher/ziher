require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user1)
    @category = categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test "index should have selecting years" do
    get :index
    years = Category.get_all_years()
    years.each do |year|
      assert_select "select option[value=#{year}]"
    end
  end

  test "index should have selecting expense or income" do
    get :index
    assert_select "select[name='isExpense'] option[value=true]"
    assert_select "select[name='isExpense'] option[value=false]"
  end

  test "index should have search button" do
    get :index
    assert_select "input[type=submit][value=#{I18n.t('search')}]"
  end

  test "should search by selected criteria" do
    get :index, year: 2012, isExpense: true
    assert_select "tr", 2
  end

  test "selected criteria should stay selected" do
    get :index, year: 2012, isExpense: true
    assert_select "select[name='year'] option[selected][value='2012']"
    assert_select "select[name='isExpense'] option[selected][value='true']"
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create category" do
    assert_difference('Category.count') do
      post :create, category: @category.attributes
    end

    assert_redirected_to category_path(assigns(:category))
  end

  test "should show category" do
    get :show, id: @category.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @category.to_param
    assert_response :success
  end

  test "should update category" do
    put :update, id: @category.to_param, category: @category.attributes
    assert_redirected_to category_path(assigns(:category))
  end

  test "should destroy category" do
    assert_difference('Category.count', -1) do
      delete :destroy, id: @category.to_param
    end

    assert_redirected_to categories_path
  end
end
