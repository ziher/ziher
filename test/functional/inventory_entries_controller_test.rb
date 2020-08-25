require 'test_helper'

class InventoryEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:master_1zgm)
    @inventory_entry = inventory_entries(:one)
  end

  test "should get index" do
    get inventory_entries_path
    assert_response :success
    assert_not_nil assigns(:inventory_entries)
  end

  test "should get new" do
    get new_inventory_entry_path(:unit_id => @inventory_entry.unit_id)
    assert_response :success
  end

  test "should create inventory_entry" do
    assert_difference('InventoryEntry.count') do
      post inventory_entries_url, params: {inventory_entry: @inventory_entry.attributes}
    end

    assert_redirected_to inventory_entry_path(assigns(:inventory_entry))
  end

  test "should show inventory_entry" do
    get edit_inventory_entry_path(@inventory_entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_inventory_entry_path(@inventory_entry)
    assert_response :success
  end

  test "should update inventory_entry" do
    put inventory_entry_url(@inventory_entry), params: {inventory_entry: {name: "updated"}}
    assert_redirected_to inventory_entry_path(assigns(:inventory_entry))
  end

  test "should destroy inventory_entry" do
    assert_difference('InventoryEntry.count', -1) do
      delete inventory_entry_path(@inventory_entry)
    end

    assert_redirected_to inventory_entries_path
  end
end
