require 'test_helper'

class CashEntriesControllerTest < ActionController::TestCase
  setup do
    @cash_entry = cash_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cash_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cash_entry" do
    assert_difference('CashEntry.count') do
      post :create, cash_entry: @cash_entry.attributes
    end

    assert_redirected_to cash_entry_path(assigns(:cash_entry))
  end

  test "should show cash_entry" do
    get :show, id: @cash_entry.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cash_entry.to_param
    assert_response :success
  end

  test "should update cash_entry" do
    put :update, id: @cash_entry.to_param, cash_entry: @cash_entry.attributes
    assert_redirected_to cash_entry_path(assigns(:cash_entry))
  end

  test "should destroy cash_entry" do
    assert_difference('CashEntry.count', -1) do
      delete :destroy, id: @cash_entry.to_param
    end

    assert_redirected_to cash_entries_path
  end
end
