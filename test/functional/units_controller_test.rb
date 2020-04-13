require 'test_helper'

class UnitsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:admin)
    @unit = units(:troop_1zgm)
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
      post :create, params: {unit: @unit.attributes}
    end

    assert_redirected_to unit_path(assigns(:unit))
  end

  test "should show unit" do
    get :show, params: {id: @unit.to_param}
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: {id: @unit.to_param}
    assert_response :success
  end

  test "should update unit" do
    put :update, params: {id: @unit.to_param, unit: @unit.attributes}
    assert_redirected_to unit_path(assigns(:unit))
  end

  test "should not destroy unit" do
    assert_difference('Unit.count', 0) do
      delete :destroy, params: {id: @unit.to_param}
    end

    assert_redirected_to units_path
  end
end
