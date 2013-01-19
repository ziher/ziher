require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    sign_in users(:admin)
    @user = users(:admin)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should show user" do
    get :show, id: @user.to_param
    assert_response :success
  end

  test "should get edit user" do
    get :edit, id: @user.to_param
    assert_response :success
  end

  test "should get new user" do
    get :new
    assert_response :success
  end
end
