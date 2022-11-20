require 'test_helper'

class GrantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
    @grant = grants(:one)
  end

  test "should get index" do
    get grants_url
    assert_response :success
  end

  test "should get new" do
    get new_grant_url
    assert_response :success
  end

  test "should create grant" do
    assert_difference('Grant.count') do
      post grants_url, params: { grant: { description: @grant.description, name: @grant.name } }
    end

    assert_redirected_to grant_url(Grant.last)
  end

  test "should show grant" do
    get grant_url(@grant)
    assert_response :success
  end

  test "should get edit" do
    get edit_grant_url(@grant)
    assert_response :success
  end

  test "should update grant" do
    patch grant_url(@grant), params: { grant: { description: @grant.description, name: @grant.name } }
    assert_redirected_to grant_url(@grant)
  end

  test "should not update grant if not admin" do
    sign_in users(:master_1zgm)
    patch grant_url(@grant), params: { grant: { description: @grant.description, name: @grant.name } }

    assert_response :redirect
    assert_redirected_to root_path
  end

  test "should destroy grant" do
    assert_difference('Grant.count', -1) do
      delete grant_url(@grant)
    end

    assert_redirected_to grants_url
  end
end
