require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  fixtures :entries

  test "should not save entry without items" do
    entry = Entry.new
    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should not save entry with multiple items of one category" do
    entry = Entry.new
    category = Category.create
    item1 = Item.new(:category => category)
    item2 = Item.new(:category => category)
    entry.items << item1 << item2

    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should not add item with duplicate category" do
    entry = Entry.create
    category = Category.create
    item1 = Item.new(:category => category)
    item2 = Item.new(:category => category)
    items = []
    items << item1 << item2

    assert_raise(ActiveRecord::RecordInvalid){
      entry.update_attributes!(:items => items)
    }
  end

  test "should save entry with items of different categories" do
    entry = Entry.new
    category1 = Category.create
    category2 = Category.create
    item1 = Item.new(:category => category1)
    item2 = Item.new(:category => category2)
    entry.items << item1 << item2

    assert entry.save
  end

  test "should add items to existing entry" do
    entry = Entry.create
    category1 = Category.create
    category2 = Category.create
    item1 = Item.new(:category => category1)
    entry.items << item1
    entry.save!
    item2 = Item.new(:category => category2)
    entry.items << item2

    assert entry.save!
  end

  test "get amount for category should return 0 when there is no item for this category" do
    entry = Entry.create
    category = Category.create

    assert_equal(0, entry.get_amount_for_category(category.id))
  end

  test "get amount for category should return 0 when item for this category has nil amount" do
    entry = Entry.create
    category = Category.create
    item = Item.create(:category=>category, :amount=>nil)
    entry.items << item

    assert_equal(0, entry.get_amount_for_category(category.id))
  end

  test "get amount for category should return nonzero value when such item exists" do
    entry = Entry.create
    category = Category.create
    item = Item.create(:category=>category, :amount=>5)
    entry.items << item

    assert_equal(5, entry.get_amount_for_category(category.id))
  end
end

