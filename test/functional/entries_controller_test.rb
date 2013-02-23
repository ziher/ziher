require 'test_helper'

class EntriesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user1)
    @entry = entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:entries)
  end

  test "should get new" do
    get :new, journal_id: @entry.journal_id
    assert_response :success
  end

  test "should create entry" do
    assert_difference('Entry.count') do

      new_hash = @entry.attributes
      items_hash = Hash.new
      i = 0
      @entry.items.each do |item|
        items_hash[i.to_s] = item.attributes
        items_hash[i.to_s]["id"] = nil
        i += 1
      end
      new_hash["items_attributes"] = items_hash
      new_hash["id"] = nil

      post :create, entry: new_hash
    end

    assert_redirected_to entry_path(assigns(:entry))
  end

  test "should show all possible categories when editing existing entry" do
    get :edit, id: @entry.to_param
    assert_select "input.category", Category.where(:year => @entry.journal.year).count
    Category.where(:year => @entry.journal.year).each do |category|
      assert_select "input.category_id[value='#{category.id}']", true
    end
  end

  test "should not show categories from different years" do
    get :edit, id: @entry.to_param
    Category.where('year <> ?', @entry.journal.year).each do |category|
      assert_select "input.category_id[value='#{category.id}']", false
    end
  end

  test "should not show duplicate categories when editing existing entry" do
    get :edit, id: @entry.to_param
    put :update, id: @entry.to_param, entry: @entry.attributes
    get :edit, id: @entry.to_param
    assert_select "input.category", Category.where(:year => @entry.journal.year).count
  end

  test "should show entry" do
    get :show, id: @entry.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @entry.to_param
    assert_response :success
  end

  test "should edit items when editing entry" do
    get :edit, id: @entry.to_param
    assert_select "input.category"
  end

  test "should update entry" do
    put :update, id: @entry.to_param, entry: @entry.attributes
    assert_redirected_to entry_path(assigns(:entry))
  end

  test "should destroy entry" do
    assert_difference('Entry.count', -1) do
      delete :destroy, id: @entry.to_param
    end

    assert_redirected_to journal_path(@entry.journal)
  end

  test "should not save empty items" do
    # remove amount from one of the items
    assert_difference('Item.count') do
      @entry.items[0].amount = 0
      new_hash = @entry.attributes
      items_hash = Hash.new
      i = 0
      @entry.items.each do |item|
        items_hash[i.to_s] = item.attributes
        items_hash[i.to_s]["id"] = nil
        i += 1
      end
      new_hash["items_attributes"] = items_hash
      new_hash["id"] = nil

      post :create, entry: new_hash
    end
  end

  test "should delete items associated with entry" do
    items_count = @entry.items.count
    assert_difference('Item.count', items_count * -1) do
      delete :destroy, id: @entry.to_param
    end
  end
end
