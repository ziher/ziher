require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test 'should not save item when amount one percent is greater than amount and category is not one percent' do
    #given
    item = items(:one)
    item.amount = 1

    #when
    item.amount_one_percent = 2

    #then
    assert_raise(ActiveRecord::RecordInvalid) {
      item.save!
    }
  end

  test 'should save item when amount one percent is lesser than amount' do
    #given
    item = items(:one)
    item.amount = 2

    #when
    item.amount_one_percent = 1

    #then
    assert item.save!
  end

  test 'should save item when amount one percent is equal amount' do
    #given
    item = items(:one)
    item.amount = 2

    #when
    item.amount_one_percent = 2

    #then
    assert item.save!
  end

  test 'should not allow amount one percent if amount is nil' do
    #given
    item = items(:one)
    item.amount = nil

    #when
    item.amount_one_percent = 2

    #then
    assert_raise(ActiveRecord::RecordInvalid) {
      item.save!
    }
  end

  test 'should update amount one percent if category type is one percent' do
    #given
    item = items(:income_one_percent)
    item.amount = 2
    item.amount_one_percent = 0

    #when
    item.save!

    #then
    assert_equal(item.amount_one_percent, item.amount)
  end

  test 'should decrease amount one percent if amount is less than it and category type is one percent' do
    #given
    item = items(:income_one_percent)
    item.amount = 2
    item.amount_one_percent = 4

    #when
    item.save!

    #then
    assert_equal(item.amount_one_percent, 2)
    assert_equal(item.amount_one_percent, item.amount)
  end

  test 'should not update amount one percent if category type is not one percent' do
    #given
    item = items(:one)
    amount = 2
    one_percent = 1

    #when
    item.amount = amount
    item.amount_one_percent = one_percent
    item.save!

    #then
    assert_equal(item.amount_one_percent, one_percent)
    assert_equal(item.amount, amount)
    assert_not_equal(item.amount_one_percent, item.amount)
  end

  test 'should normalize amount' do
    #given
    item = items(:one)
    item.amount = '1 234,56'

    #when
    item.save!

    #then
    assert_equal(item.amount, 1234.56)
  end

  test 'should normalize amount one percent' do
    #given
    item = items(:four)
    item.amount_one_percent = '1 23,45'

    #when
    item.save!

    #then
    assert_equal(item.amount_one_percent, 123.45)
  end

end
