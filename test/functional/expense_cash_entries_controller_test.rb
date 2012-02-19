require 'test_helper'

class ExpenseCashEntriesControllerTest < ActionController::TestCase
  setup do
    @expense_cash_entry = expense_cash_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expense_cash_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create expense_cash_entry" do
    assert_difference('ExpenseCashEntry.count') do
      post :create, expense_cash_entry: @expense_cash_entry.attributes
    end

    assert_redirected_to expense_cash_entry_path(assigns(:expense_cash_entry))
  end

  test "should show expense_cash_entry" do
    get :show, id: @expense_cash_entry.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @expense_cash_entry.to_param
    assert_response :success
  end

  test "should update expense_cash_entry" do
    put :update, id: @expense_cash_entry.to_param, expense_cash_entry: @expense_cash_entry.attributes
    assert_redirected_to expense_cash_entry_path(assigns(:expense_cash_entry))
  end

  test "should destroy expense_cash_entry" do
    assert_difference('ExpenseCashEntry.count', -1) do
      delete :destroy, id: @expense_cash_entry.to_param
    end

    assert_redirected_to expense_cash_entries_path
  end
end
