require 'test_helper'

class JournalsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user1)
    @journal = journals(:finance_2012)
    @new_journal = Journal.new(:journal_type => journal_types(:finance), :year => 2014)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:journals)
  end

  test "should show zeros for empty items when showing all entries" do
    get :show, id: @journal.to_param
    assert_select "td", "0" 
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create journal" do
    assert_difference('Journal.count') do
      post :create, journal: @new_journal.attributes
    end

    assert_redirected_to journal_path(assigns(:journal))
  end

  test "should show journal" do
    get :show, id: @journal.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @journal.to_param
    assert_response :success
  end

  test "should destroy journal" do
    assert_difference('Journal.count', -1) do
      delete :destroy, id: @journal.to_param
    end

    assert_redirected_to journals_path
  end

  test "should show initial balance" do
    get :show, id: @journal.to_param
    assert_select "#initial-balance", @journal.initial_balance.to_s
  end
end
