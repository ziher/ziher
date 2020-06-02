require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in users(:master_1zgm)
    get "/home/index"
    assert_response :success
  end
end
