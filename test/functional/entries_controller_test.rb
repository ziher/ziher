require 'test_helper'

class EntriesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:master_1zgm)
    @entry = entries(:expense_one)
    @entry_income = entries(:income_one)
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

    assert_redirected_to journal_path(@entry.journal)
  end

  test "should show all possible categories when editing existing expense entry" do
    get :edit, id: @entry.to_param
    assert_select "input.category", Category.where(:year => @entry.journal.year, :is_expense => @entry.is_expense).count * 2
    #przenoszenie kwot miedzy ksiazkami na razie wstrzymane
    #+ Category.where(:year => @entry.journal.year, :is_expense => !@entry.is_expense).count
    Category.where(:year => @entry.journal.year, :is_expense => @entry.is_expense).each do |category|
      assert_select "input.category_id[value='#{category.id}']", true
    end
  end

  test "should show all possible categories when editing existing income entry" do
    get :edit, id: @entry_income.to_param
    assert_select "input.category", Category.where(:year => @entry_income.journal.year, :is_expense => @entry_income.is_expense).count
    Category.where(:year => @entry_income.journal.year, :is_expense => @entry_income.is_expense).each do |category|
      assert_select "input.category_id[value='#{category.id}']", true
    end
  end

  test "should not show categories from different years" do
    get :edit, id: @entry.to_param
    Category.where('year <> ?', @entry.journal.year).each do |category|
      assert_select "input.category_id[value='#{category.id}']", false
    end
  end

  test "should not show duplicate categories when editing existing expense entry" do
    get :edit, id: @entry.to_param
    put :update, id: @entry.to_param, entry: @entry.attributes
    get :edit, id: @entry.to_param
    assert_select "input.category", Category.where(:year => @entry.journal.year, :is_expense => @entry.is_expense).count * 2
    #przenoszenie kwot miedzy ksiazkami na razie wstrzymane
    #+ Category.where(:year => @entry.journal.year, :is_expense => !@entry.is_expense).count
  end

  test "should not show duplicate categories when editing existing income entry" do
    get :edit, id: @entry_income.to_param
    put :update, id: @entry_income.to_param, entry: @entry_income.attributes
    get :edit, id: @entry_income.to_param
    assert_select "input.category", Category.where(:year => @entry_income.journal.year, :is_expense => @entry_income.is_expense).count
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
    assert_redirected_to journal_path(assigns(:journal))
  end

  test "should destroy entry" do
    assert_difference('Entry.count', -1) do
      delete :destroy, id: @entry.to_param
    end

    assert_redirected_to journal_path(@entry.journal)
  end


  test 'should not save empty entry' do
    # given
    entries_count_before = Entry.count
    empty_entry = copy_to_new_hash(@entry)
    reset_amounts(empty_entry)

    # when
    post :create, entry: empty_entry

    #then
    entries_count_after = Entry.count
    assert_equal(entries_count_before, entries_count_after)
  end

  test "should update item amount to 0 correctly" do
    # given
    item1 = items(:one)
    item2 = items(:two)
    # item2.amount = 0

    puts "#{@entry.items.count}, sum #{@entry.sum}, #{@entry.items[0].to_json} #{@entry.items[1].to_json}"

    # when
    put :update, id: @entry.to_param, entry: #@entry.attributes
        {"date" => "2012-10-11", "document_number" => "3", "name" => "asdf",
         "items_attributes" =>
             {"0" => {"amount" => "0", "amount_one_percent" => "", "category_id" => item1.category.id, "id" => item1.id},
              # {"0" => item1.attributes,
              # "1" => {"amount" => "100.0", "amount_one_percent" => "", "category_id" => "82", "id" => @entry.items[1].id}},
              "1" => item2.attributes},
         "journal_id" => "5", "is_expense" => "true"}

    puts "#{@entry.items.count}, sum #{@entry.sum}, #{@entry.items[0].to_json} #{@entry.items[1].to_json}"

    # then
    assert_equal(item1.amount, @entry.sum)
  end

  test "should delete items associated with entry" do
    items_count = @entry.items.count
    assert_difference('Item.count', items_count * -1) do
      delete :destroy, id: @entry.to_param
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
