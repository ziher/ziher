require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in users(:scoutmaster_dukt)
    get :index
    assert_response :success
  end
end
