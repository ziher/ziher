require 'test_helper'

class UnitsControllerTest < ActionController::TestCase
  setup do
    @unit = units(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:units)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create unit" do
    assert_difference('Unit.count') do
      post :create, unit: @unit.attributes
    end

    assert_redirected_to unit_path(assigns(:unit))
  end

  test "should show unit" do
    get :show, id: @unit.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @unit.to_param
    assert_response :success
  end

  test "should update unit" do
    put :update, id: @unit.to_param, unit: @unit.attributes
    assert_redirected_to unit_path(assigns(:unit))
  end

  test "should destroy unit" do
    assert_difference('Unit.count', -1) do
      delete :destroy, id: @unit.to_param
    end

    assert_redirected_to units_path
  end
end
