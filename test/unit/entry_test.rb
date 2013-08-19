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

  test "should not save entry when amount one percent is greater than amount" do
    entry = entries(:expense_one)
    entry.items[0].amount = 1
    entry.items[0].amount_one_percent = 2
    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should save entry when amount one percent is lesser than amount" do
    entry = entries(:expense_one)
    entry.items[0].amount = 2
    entry.items[0].amount_one_percent = 1
    assert entry.save!
  end

  test "should save entry when amount one percent is equal amount" do
    entry = entries(:expense_one)
    entry.items[0].amount = 2
    entry.items[0].amount_one_percent = 2
    assert entry.save!
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

    item1 = Item.new(:category => category)
    item2 = Item.new(:category => category)
    entry.items << item1 << item2

    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should not add item with duplicate category" do
    entry = entries(:expense_one)
    category = categories(:one)

    item1 = Item.new(:category => category)
    item2 = Item.new(:category => category)
    items = []
    items << item1 << item2

    assert_raise(ActiveRecord::RecordInvalid){
      entry.update_attributes!(:items => items)
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
    item1 = Item.new(:category => categories(:seven))
    item2 = Item.new(:category => categories(:eight))
    entry.items << item1 << item2

    assert entry.save!
  end

  test "should add items to existing entry" do
    entry = entries(:expense_one)

    item2 = Item.new(:category => categories(:seven))
    entry.items << item2
    assert entry.save!
  end
  
  test "get amount for category should return 0 when there is no item for this category" do
    entry = Entry.create
    category = categories(:one)

    assert_equal(0, entry.get_amount_for_category(category.id))
  end

  test "get amount for category should return 0 when item for this category has nil amount" do
    entry = Entry.create
    category = categories(:one)
    item = Item.create(:category => category, :amount => nil)
    entry.items << item

    assert_equal(0, entry.get_amount_for_category(category.id))
  end

  test "get amount for category should return nonzero value when such item exists" do
    entry = Entry.create
    category = categories(:one)
    item = Item.create(:category => category, :amount => 5)
    entry.items << item

    assert_equal(5, entry.get_amount_for_category(category.id))
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

    assert_no_difference('journal.entries.count') {
      entry.destroy
    }
  end

  test "should count sum of items" do
    entry = entries(:expense_one)

    expected_sum = 0
    Item.find_all_by_entry_id(entry.id).each do |item|
      expected_sum += item.amount
    end

    assert_equal expected_sum, entry.sum
  end
end
