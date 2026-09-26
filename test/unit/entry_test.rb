require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  fixtures :categories
  fixtures :journals

  test "should not save entry without items" do
    entry = entries(:expense_one)
    entry.items = []
    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should not save entry without journal" do
    entry = entries(:expense_one)
    entry.journal = nil
    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should not save entry with multiple items of one category" do
    entry = entries(:expense_one)
    category = categories(:one)

    item1 = Item.new(:amount => 0, :category => category)
    item2 = Item.new(:amount => 0, :category => category)
    entry.items << item1 << item2

    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should not add item with duplicate category" do
    entry = entries(:expense_one)
    category = categories(:one)

    item1 = Item.new(:amount => 0, :category => category)
    item2 = Item.new(:amount => 0, :category => category)
    items = []
    items << item1 << item2

    assert_raise(ActiveRecord::RecordInvalid){
      entry.update!(:items => items)
    }
  end

  test "should not save entry from different year" do
    #given
    entry = entries(:expense_one)

    #when - the date is from previous year (from 12 months before)
    entry.date <<= 12

    #then
    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should not save entry with items of categories from different year" do
    entry = entries(:expense_one)
    item1 = Item.new(:category => categories(:one))
    entry.items << item1

    assert_raise(ActiveRecord::RecordInvalid){
      assert entry.save!
    }
  end

  test "should save entry with items of different categories" do
    entry = entries(:expense_one)
    item1 = Item.new(:amount => 0, :category => categories(:seven))
    item2 = Item.new(:amount => 0, :category => categories(:eight))
    entry.items << item1 << item2

    assert entry.save!
  end

  test "should add items to existing entry" do
    entry = entries(:expense_one)

    item2 = Item.new(:amount => 0, :category => categories(:seven))
    entry.items << item2
    assert entry.save!
  end
  
  test "get amount for category should return 0 when there is no item for this category" do
    entry = Entry.create
    category = categories(:one)

    assert_equal(0, entry.get_amount_for_category(category))
  end

  test "get amount for category should return 0 when item for this category has nil amount" do
    entry = Entry.create
    category = categories(:one)
    item = Item.create(:category => category, :amount => nil)
    entry.items << item

    assert_equal(0, entry.get_amount_for_category(category))
  end

  test "get amount for category should return nonzero value when such item exists" do
    entry = Entry.create
    category = categories(:one)
    item = Item.create(:category => category, :amount => 5)
    entry.items << item

    assert_equal(5, entry.get_amount_for_category(category))
  end

  test "should not allow entry being both income and expense" do
    #given
    entry = Entry.create
    entry.journal = journals(:finance_2012)
    income_item = Item.create(:category => categories(:two), :amount => 1)
    expense_item = Item.create(:category => categories(:five), :amount => 1)

    #when
    entry.items << income_item << expense_item

    #then
    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should save entry when the journal is opened" do
    entry = entries(:expense_one)
    entry.journal.is_open = true

    assert entry.save!
  end

  test "should not save entry when the journal is closed" do
    entry = entries(:expense_one)
    entry.journal.is_open = false
    entry.journal.blocked_to = Date.new(entry.journal.year).end_of_year

    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should not add entry when the journal is closed" do
    entry = Entry.create
    category = categories(:one)
    item = Item.create(:category => category, :amount => 5)
    entry.items << item
    entry.journal = journals(:finance_2012)
    entry.journal.is_open = false

    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should not delete entry when the journal is closed" do
    entry = entries(:expense_one)
    journal = entry.journal
    journal.is_open = false
    journal.blocked_to = Date.new(journal.year).end_of_year

    assert_no_difference('journal.entries.count') {
      entry.destroy
    }
  end

  test "should count sum of items" do
    entry = entries(:expense_one)

    expected_sum = 0
    Item.where(entry: entry).each do |item|
      expected_sum += item.amount
    end

    assert_equal expected_sum, entry.sum
  end

  test "linked entry sum must match" do
    #given
    entry = entries(:expense_one)
    entry.items = [Item.create(:category => categories(:five), :amount => 100)]
    linked = entries(:income_one)
    linked.items = [Item.create(:category => categories(:two), :amount => 200)]

    #when
    entry.linked_entry = linked
    
    #then    
    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "income cannot be linked to income" do
    #given
    entry = entries(:expense_one)
    entry.items = [Item.create(:category => categories(:five), :amount => 100)]
    linked = entries(:expense_two)
    linked.items = [Item.create(:category => categories(:two), :amount => 100)]

    #when
    entry.linked_entry = linked
    
    #then    
    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should keep grants of a new entry in memory when validation fails" do
    #given
    grant = grants(:one)
    entry = Entry.new(:name => "x", :document_number => "d", :journal => journals(:finance_2012), :is_expense => true,
                      :date => nil,
                      :items_attributes => [
                        {:category_id => categories(:five).id, :amount => 10, :amount_one_percent => 2,
                         :item_grants_attributes => [{:grant_id => grant.id, :amount => 3}]},
                        {:category_id => categories(:six).id, :amount => 5,
                         :item_grants_attributes => [{:grant_id => grant.id, :amount => 0}]},
                        {:category_id => categories(:seven).id, :amount => 5,
                         :item_grants_attributes => [{:grant_id => grant.id, :amount => nil}]}])

    #when
    valid = entry.valid?

    #then
    assert_not valid
    assert_equal ["Data wpisu nie może być pusta"], entry.errors.full_messages

    item = entry.items.find { |i| i.category_id == categories(:five).id }
    live_grants = item.item_grants.reject(&:destroyed?)
    assert_equal 1, live_grants.size
    assert_equal grant.id, live_grants.first.grant_id
    assert_equal 3, live_grants.first.amount

    # sums do not count grants removed by Item#remove_*_amount_grants and do not raise on them
    assert_equal 3, entry.get_sum_for_grant(grant)
    assert_equal 3, entry.get_amount_for_category_and_grant(categories(:five), grant)
    assert_equal 0, entry.get_amount_for_category_and_grant(categories(:six), grant)
    assert_equal 0, entry.get_amount_for_category_and_grant(categories(:seven), grant)
  end

  test "should count income sum one percent for category" do
    #given
    entry = entries(:income_one)

    #when
    expected_amount = entry.items.select{|item| item.category.is_one_percent}.sum(&:amount_one_percent)

    #then
    assert_not_equal 0, expected_amount
    assert_equal expected_amount, entry.sum_one_percent
  end

end
