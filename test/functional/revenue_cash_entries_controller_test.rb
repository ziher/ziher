require 'test_helper'

class RevenueCashEntriesControllerTest < ActionController::TestCase
  setup do
    @revenue_cash_entry = revenue_cash_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:revenue_cash_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create revenue_cash_entry" do
    assert_difference('RevenueCashEntry.count') do
      post :create, revenue_cash_entry: @revenue_cash_entry.attributes
    end

    assert_redirected_to revenue_cash_entry_path(assigns(:revenue_cash_entry))
  end

  test "should show revenue_cash_entry" do
    get :show, id: @revenue_cash_entry.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @revenue_cash_entry.to_param
    assert_response :success
  end

  test "should update revenue_cash_entry" do
    put :update, id: @revenue_cash_entry.to_param, revenue_cash_entry: @revenue_cash_entry.attributes
    assert_redirected_to revenue_cash_entry_path(assigns(:revenue_cash_entry))
  end

  test "should destroy revenue_cash_entry" do
    assert_difference('RevenueCashEntry.count', -1) do
      delete :destroy, id: @revenue_cash_entry.to_param
    end

    assert_redirected_to revenue_cash_entries_path
  end
end
