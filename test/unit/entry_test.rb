require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  fixtures :categories

  test "should not save entry without items" do
    entry = entries(:one)
    entry.items = []
    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should not save entry without journal" do
    entry = entries(:one)
    entry.journal = nil
    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should not save entry with multiple items of one category" do
    entry = entries(:one)
    category = categories(:one)

    item1 = Item.new(:category => category)
    item2 = Item.new(:category => category)
    entry.items << item1 << item2

    assert_raise(ActiveRecord::RecordInvalid){
      entry.save!
    }
  end

  test "should not add item with duplicate category" do
    entry = entries(:one)
    category = categories(:one)

    item1 = Item.new(:category => category)
    item2 = Item.new(:category => category)
    items = []
    items << item1 << item2

    assert_raise(ActiveRecord::RecordInvalid){
      entry.update_attributes!(:items => items)
    }
  end

  test "should save entry with items of different categories" do
    entry = entries(:one)
    item1 = Item.new(:category => categories(:three))
    item2 = Item.new(:category => categories(:four))
    entry.items << item1 << item2

    assert entry.save!
  end

  test "should add items to existing entry" do
    entry = entries(:one)

    item1 = Item.new(:category => categories(:three))
    entry.items << item1
    entry.save!

    item2 = Item.new(:category => categories(:four))
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
end

