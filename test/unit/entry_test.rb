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
		entry.items << item1

		assert entry.save!
	end
end

