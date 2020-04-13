require 'test_helper'

class UnitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
    @unit = units(:troop_1zgm)
  end

  test "should get index" do
    get units_path
    assert_response :success
    assert_not_nil assigns(:units)
  end

  test "should get new" do
    get new_unit_path
    assert_response :success
  end

  test "should create unit" do
    assert_difference('Unit.count', 1) do
      post units_url, params: {unit: {name: "created"}}
    end

    assert_redirected_to unit_path(assigns(:unit))
  end

  test "should show unit" do
    get unit_path(@unit)
    assert_response :success
  end

  test "should get edit" do
    get edit_unit_path(@unit)
    assert_response :success
  end

  test "should update unit" do
    put unit_url(@unit), params: {unit: {name: "updated"}}
    assert_redirected_to unit_path(assigns(:unit))
  end

  test "should not destroy unit" do
    assert_difference('Unit.count', 0) do
      delete unit_path(@unit)
    end

    assert_redirected_to units_path
  end
end
