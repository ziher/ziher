require 'test_helper'

class InventoryJournalsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user1)
    @inventory_journal = inventory_journals(:one)
  end

  test "should get index" do
#    get :index
#    assert_response :success
#    assert_not_nil assigns(:inventory_journals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create inventory_journal" do
    assert_difference('InventoryJournal.count') do
      post :create, inventory_journal: @inventory_journal.attributes
    end

    assert_redirected_to inventory_journal_path(assigns(:inventory_journal))
  end

  test "should show inventory_journal" do
#    get :show, id: @inventory_journal.to_param
#    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @inventory_journal.to_param
    assert_response :success
  end

  test "should update inventory_journal" do
    put :update, id: @inventory_journal.to_param, inventory_journal: @inventory_journal.attributes
    assert_redirected_to inventory_journal_path(assigns(:inventory_journal))
  end

  test "should destroy inventory_journal" do
    assert_difference('InventoryJournal.count', -1) do
      delete :destroy, id: @inventory_journal.to_param
    end

    assert_redirected_to inventory_journals_path
  end
end
