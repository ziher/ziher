require 'test_helper'

class InventorySourcesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:admin)
    @inventory_source = inventory_sources(:one)
  end

  # TODO: should not delete source if has linked entries
  # TODO: should not update finance nor bank source

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:inventory_sources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create inventory_source" do
    assert_difference('InventorySource.count') do
      post :create, inventory_source: { is_active: @inventory_source.is_active, name: @inventory_source.name + "_tmp" }
    end

    assert_redirected_to inventory_source_path(assigns(:inventory_source))
  end

  test "should show inventory_source" do
    get :show, id: @inventory_source
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @inventory_source
    assert_response :success
  end

  test "should update inventory_source" do
    put :update, id: @inventory_source, inventory_source: { is_active: @inventory_source.is_active, name: @inventory_source.name }
    assert_redirected_to inventory_source_path(assigns(:inventory_source))
  end

  test "should destroy inventory_source" do
    assert_difference('InventorySource.count', -1) do
      delete :destroy, id: inventory_sources(:three)
    end

    assert_redirected_to inventory_sources_path
  end
end
