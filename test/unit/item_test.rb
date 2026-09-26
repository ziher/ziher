require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test 'fixtures should be valid' do
    Item.all.each do |item|
      assert item.valid?, "item #{item.id} (#{item.category&.name}): #{item.errors.full_messages.join(', ')}"
    end
  end

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

  # items(:three): an expense item (category :five) without grants, so only the amount vs 1,5% rule
  # is exercised here - items(:one) carries grants that take part in the sum validation
  test 'should save item when amount one percent is lesser than amount' do
    #given
    item = items(:three)
    item.amount = 2

    #when
    item.amount_one_percent = 1

    #then
    assert item.save!
  end

  test 'should save item when amount one percent is equal amount' do
    #given
    item = items(:three)
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

    #when
    item.amount_one_percent = 4
    item.save!

    #then
    assert_equal(item.amount_one_percent, item.amount)
  end

  test 'should not update amount one percent if category type is not one percent' do
    #given
    item = items(:three)
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


  test 'should not allow more than one item grant amount for same grant' do
    skip "not implemented"
  end

  test 'should not allow for grants with diferent amount sign than self amount' do
    skip "not implemented"
  end

  test 'should not allow absolute value of grants amounts sum bigger than abs of self sum' do
    skip "not implemented"
  end

  test 'should allow positive value for income category' do
    skip "not implemented"
  end

  test 'should allow negative value for income category' do
    skip "not implemented"
  end

  test 'should allow positive value for expense category' do
    skip "not implemented"
  end

  test 'should allow negative values for expense categry' do
    skip "not implemented"
  end

  test 'should allow positive value for grant amount in expense category' do
    skip "not implemented"
  end

  test 'should allow negative value for grant amount in expense category' do
    skip "not implemented"
  end

end
