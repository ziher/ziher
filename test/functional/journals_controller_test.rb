require 'test_helper'

class JournalsControllerTest < ActionController::TestCase
  setup do
    @journal = journals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:journals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create journal" do
    assert_difference('Journal.count') do
      post :create, journal: @journal.attributes
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

  test "should update journal" do
    put :update, id: @journal.to_param, journal: @journal.attributes
    assert_redirected_to journal_path(assigns(:journal))
  end

  test "should destroy journal" do
    assert_difference('Journal.count', -1) do
      delete :destroy, id: @journal.to_param
    end

    assert_redirected_to journals_path
  end
end
