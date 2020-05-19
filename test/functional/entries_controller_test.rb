require 'test_helper'

class EntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:master_1zgm)
    @entry = entries(:expense_one)
    @entry_income = entries(:income_one)
  end

  test "should get new" do
    # get :new, params: {journal_id: @entry.journal_id}
    get new_entry_path, params: {journal_id: @entry.journal_id}
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

      post entries_url, params: {entry: new_hash}
    end

    assert_redirected_to journal_path(@entry.journal)
  end

  test "should show all possible categories when editing existing expense entry" do
    get edit_entry_path(@entry)
    assert_select "input.category", Category.where(:year => @entry.journal.year, :is_expense => @entry.is_expense).count * 2
    #przenoszenie kwot miedzy ksiazkami na razie wstrzymane
    #+ Category.where(:year => @entry.journal.year, :is_expense => !@entry.is_expense).count
    Category.where(:year => @entry.journal.year, :is_expense => @entry.is_expense).each do |category|
      assert_select "input.category_id[value='#{category.id}']", true
    end
  end

  test "should show all possible categories when editing existing income entry" do
    get edit_entry_path(@entry_income)
    assert_select "input.category", Category.where(:year => @entry_income.journal.year, :is_expense => @entry_income.is_expense).count
    Category.where(:year => @entry_income.journal.year, :is_expense => @entry_income.is_expense).each do |category|
      assert_select "input.category_id[value='#{category.id}']", true
    end
  end

  test "should not show categories from different years" do
    get edit_entry_path(@entry)
    Category.where('year <> ?', @entry.journal.year).each do |category|
      assert_select "input.category_id[value='#{category.id}']", false
    end
  end

  test "should not show duplicate categories when editing existing expense entry" do
    get edit_entry_path(@entry)
    put entry_url(@entry), params: {entry: {name: "updated"}}
    get edit_entry_path(@entry)
    assert_select "input.category", Category.where(:year => @entry.journal.year, :is_expense => @entry.is_expense).count * 2
    #przenoszenie kwot miedzy ksiazkami na razie wstrzymane
    #+ Category.where(:year => @entry.journal.year, :is_expense => !@entry.is_expense).count
  end

  test "should not show duplicate categories when editing existing income entry" do
    get edit_entry_path(@entry_income)
    put entry_url(@entry_income), params: {entry: {name: "updated"}}
    get edit_entry_path(@entry_income)
    assert_select "input.category", Category.where(:year => @entry_income.journal.year, :is_expense => @entry_income.is_expense).count
  end

  test "should show entry" do
    get entry_path(@entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_entry_path(@entry)
    assert_response :success
  end

  test "should edit items when editing entry" do
    get edit_entry_path(@entry)
    assert_select "input.category"
  end

  test "should update entry" do
    put entry_url(@entry), params: {entry: {name: "updated"}}
    assert_redirected_to journal_path(assigns(:journal))
  end

  test "should destroy entry" do
    assert_difference('Entry.count', -1) do
      delete entry_path(@entry)
    end

    assert_redirected_to journal_path(@entry.journal)
  end


  test 'should not save empty entry' do
    # given
    entries_count_before = Entry.count
    empty_entry = copy_to_new_hash(@entry)
    reset_amounts(empty_entry)

    # when
    post entries_url, params: {entry: empty_entry}

    #then
    entries_count_after = Entry.count
    assert_equal(entries_count_before, entries_count_after)
  end

  test "should delete items associated with entry" do
    items_count = @entry.items.count
    assert_difference('Item.count', items_count * -1) do
      delete entry_path(@entry)
    end
  end

  def copy_to_new_hash(entry)
    new_hash = entry.attributes
    items_hash = Hash.new
    i = 0
    entry.items.each do |item|
      items_hash[i.to_s] = item.attributes
      items_hash[i.to_s]['id'] = nil
      i += 1
    end
    new_hash['items_attributes'] = items_hash
    new_hash['id'] = nil
    new_hash
  end

  def reset_amounts(entry)
    (0 .. entry['items_attributes'].length - 1).each {|i|
      entry['items_attributes'][i.to_s]['amount'] = 0
    }
  end
end
