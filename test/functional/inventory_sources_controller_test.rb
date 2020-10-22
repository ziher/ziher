require 'test_helper'

class InventorySourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
    @inventory_source = inventory_sources(:one)
  end

  # TODO: should not delete source if has linked entries
  # TODO: should not update finance nor bank source

  test "should get index" do
    get inventory_sources_path
    assert_response :success
    assert_not_nil assigns(:inventory_sources)
  end

  test "should get new" do
    get new_inventory_source_path
    assert_response :success
  end

  test "should create inventory_source" do
    assert_difference('InventorySource.count') do
      post inventory_sources_url, params: {inventory_source: { is_active: @inventory_source.is_active, name: @inventory_source.name + "_tmp" }}
    end

    assert_redirected_to inventory_source_path(assigns(:inventory_source))
  end

  test "should show inventory_source" do
    get inventory_source_path(@inventory_source)
    assert_response :success
  end

  test "should get edit" do
    get edit_inventory_source_path(@inventory_source)
    assert_response :success
  end

  test "should update inventory_source" do
    put inventory_source_url(@inventory_source), params: {inventory_source: { is_active: @inventory_source.is_active, name: @inventory_source.name}}
    assert_redirected_to inventory_source_path(assigns(:inventory_source))
  end

  test "should not destroy inventory_source in use" do
    assert_difference('InventorySource.count', 0) do
      delete inventory_source_path(@inventory_source)
    end

    assert_redirected_to inventory_sources_path
  end

  test "should destroy unused inventory_source" do
    assert_difference('InventorySource.count', -1) do
      delete inventory_source_path(inventory_sources(:three))
    end

    assert_redirected_to inventory_sources_path
  end
end
