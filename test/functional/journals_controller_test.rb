require 'test_helper'

class JournalsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user1)
    @journal = journals(:finance_2012)
    @new_journal = Journal.new(:journal_type => journal_types(:finance), :year => 2014, :unit => units(:one))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:journals)
  end

  test "should show dashes for empty items when showing all entries" do
    get :show, id: @journal.to_param
    assert_select "td.income", "-"
    assert_select "td.expense", "-"
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

  test "should not have access to journal" do
    get :show, id: journals(:two2012f)
    assert_unauthorized
  end
end
