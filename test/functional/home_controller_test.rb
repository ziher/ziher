require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in users(:user1)
    get :index
    assert_response :success
  end

  test "should have one menu item for each journal type" do
    sign_in users(:user1)
    get :index
    JournalType.all.each do |journal_type|
      path = journal_path(Journal.find_current_for_type(journal_type))
      assert_select "a[href='#{path}']"
    end
  end
end
