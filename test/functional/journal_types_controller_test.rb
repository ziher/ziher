require 'test_helper'

class JournalTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:master_1zgm)
    @journal_type = journal_types(:finance)
  end

  test "should get index" do
    get journal_types_path
    assert_response :success
    assert_not_nil assigns(:journal_types)
  end

  test "should get new" do
    get new_journal_type_path
    assert_response :success
  end

  test "should create journal_type" do
    assert_difference('JournalType.count') do
      post journal_types_url, params: {journal_type: {name: 'New'}}
    end

    assert_redirected_to journal_type_path(assigns(:journal_type))
  end

  test "should show journal_type" do
    get journal_type_path(@journal_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_journal_type_path(@journal_type)
    assert_response :success
  end

  test "should update journal_type" do
    put journal_type_url(@journal_type), params: {journal_type: {name: 'Changed'}}
    assert_redirected_to journal_type_path(assigns(:journal_type))
  end

  test "should destroy journal_type" do
    assert_difference('JournalType.count', -1) do
      delete journal_type_path(@journal_type)
    end

    assert_redirected_to journal_types_path
  end
end
