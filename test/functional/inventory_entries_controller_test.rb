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

  test "should get new without unit in url nor in session" do
    # url opened directly, before visiting /inventory_entries (which puts the unit in the session)
    unit = Unit.find_by_user(users(:master_1zgm)).first
    assert_not_nil unit

    get new_inventory_entry_path(:is_expense => true)

    assert_response :success
    assert_select "input[name='inventory_entry[unit_id]'][value='#{unit.id}']"
    assert_select "select[disabled] option[value='#{unit.id}']", text: unit.full_name
    assert_equal unit.id, session[:current_unit_id]
  end

  test "should get new with unit from session" do
    get inventory_entries_path(:unit_id => @inventory_entry.unit_id)
    assert_response :success

    get new_inventory_entry_path(:is_expense => false)

    assert_response :success
    assert_select "input[name='inventory_entry[unit_id]'][value='#{@inventory_entry.unit_id}']"
  end

  test "should redirect from new to index when user has no units" do
    sign_in users(:master_p_m)
    assert_empty Unit.find_by_user(users(:master_p_m))

    get new_inventory_entry_path(:is_expense => true)

    assert_redirected_to inventory_entries_path
    follow_redirect!
    assert_redirected_to inventory_entries_no_units_path
  end

  test "should render form again with unit when creating inventory_entry fails validation without unit in session" do
    assert_no_difference('InventoryEntry.count') do
      post inventory_entries_url, params: {inventory_entry: @inventory_entry.attributes.merge("name" => "")}
    end

    assert_response :success
    assert_select "input[name='inventory_entry[unit_id]'][value='#{@inventory_entry.unit_id}']"
  end

  test "should create inventory_entry" do
    assert_difference('InventoryEntry.count') do
      post inventory_entries_url, params: {inventory_entry: @inventory_entry.attributes}
    end

    assert_redirected_to inventory_entry_path(assigns(:inventory_entry))
  end

  test "should show inventory_entry" do
    get inventory_entry_path(@inventory_entry)
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
