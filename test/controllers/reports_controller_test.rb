require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  test "should get all_finance_report" do
    get :all_finance_report
    assert_response :success
  end

end
