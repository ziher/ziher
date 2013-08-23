require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test "should not save item when amount one percent is greater than amount" do
    #given
    item = items(:one)
    item.amount = 1

    #when
    item.amount_one_percent = 2

    #then
    assert_raise(ActiveRecord::RecordInvalid){
      item.save!
    }
  end

  test "should save item when amount one percent is lesser than amount" do
    #given
    item = items(:one)
    item.amount = 2

    #when
    item.amount_one_percent = 1

    #then
    assert item.save!
  end

  test "should save item when amount one percent is equal amount" do
    #given
    item = items(:one)
    item.amount = 2

    #when
    item.amount_one_percent = 2

    #then
    assert item.save!
  end

  test "should not allow amount one percent if amount is nil" do
    #given
    item = items(:one)
    item.amount = nil

    #when
    item.amount_one_percent = 2

    #then
    assert_raise(RuntimeError){
      item.save!
    }
  end
end
