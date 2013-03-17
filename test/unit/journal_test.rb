require 'test_helper'

class JournalTest < ActiveSupport::TestCase
  fixtures :journal_types
  fixtures :journals
  fixtures :categories

  test "should prevent creating two journals of the same type for the same year" do
    assert_raise(ActiveRecord::RecordInvalid){
      journal = Journal.create!(:journal_type => journal_types(:finance), :year => 2012)
    }
  end

  test "should save two journals of the same type for different years" do
    journal = Journal.create!(:journal_type => journal_types(:finance), :year => 2013)
    assert_not_nil journal
  end

  test "should save journal after it was created" do
    journal = Journal.create!(:journal_type => journal_types(:finance), :year => 2013)
    journal.save!
    assert_not_nil journal
  end

  test "should prevent saving without type" do
    assert_raise(ActiveRecord::RecordInvalid){
      journal = Journal.create!
    }
  end

  test "should save journal with type" do
    journal = Journal.create!(:journal_type => journal_types(:finance))
    assert_not_nil journal
  end

  test "should find one journal by year and type" do
    found = Journal.find_by_year_and_type(2012, journal_types(:finance))
    assert_instance_of Journal, found
  end

  test "should return nil when not found by year and type" do
    found = Journal.find_by_year_and_type(2014, journal_types(:finance))
    assert_nil found
  end

  test "should get default journal for current year" do
    year_2015 = Time.parse('2015-05-05')
    pretend_now_is(year_2015) do
      journal_2015 = journals(:finance_2015)
      assert_equal journal_2015, Journal.get_default
    end
  end

  test "should get default journal for previous year" do
    year_2016 = Time.parse('2016-06-06')
    pretend_now_is(year_2016) do
      journal_2015 = journals(:finance_2015)
      assert_equal journal_2015, Journal.get_default
    end
  end

  test "should find current journal" do
    year_2015 = Time.parse('2015-05-05')
    pretend_now_is(year_2015) do
      journal_2015 = journals(:finance_2015)
      assert_equal journal_2015, Journal.find_current_for_type(journal_types(:finance))
    end
  end

  test "should find last year journal as current" do
    year_2016 = Time.parse('2016-06-06')
    pretend_now_is(year_2016) do
      journal_2015 = journals(:finance_2015)
      assert_equal journal_2015, Journal.find_current_for_type(journal_types(:finance))
    end
  end

  test "should count sum for category" do
    journal = journals(:finance_2012)
    category = categories(:one)

    entries_for_category = Entry.find_all_by_journal_id(journal.id).map(&:id)
    items_for_category = Item.find(:all, :conditions => ['category_id = ? AND entry_id IN (?)', category.id, entries_for_category])
    expected_sum = items_for_category.sum(&:amount)

    assert_equal expected_sum, journal.get_sum_for_category(category)
  end

  test "should count expense sum" do
    journal = journals(:finance_2012)

    expected_sum = 0
    Category.all.each do |category|
      if category.is_expense
        entries_for_category = Entry.find_all_by_journal_id(journal.id).map(&:id)
        items_for_category = Item.find(:all, :conditions => ['category_id = ? AND entry_id IN (?)', category.id, entries_for_category])
        expected_sum += items_for_category.sum(&:amount)
      end
    end

    assert_equal expected_sum, journal.get_expense_sum
  end

  test "should count income sum" do
    journal = journals(:finance_2012)

    expected_sum = 0
    Category.all.each do |category|
      if not category.is_expense
        expected_sum += count_sum_for_category(journal, category)
      end
    end

    assert_equal expected_sum, journal.get_income_sum
  end

  test "should have initial balance" do
    journal = journals(:finance_2012)
    assert_not_nil journal.initial_balance
  end

  private

  def count_sum_for_category(journal, category)
      entries_for_category = Entry.find_all_by_journal_id(journal.id).map(&:id)
      items_for_category = Item.find(:all, :conditions => ['category_id = ? AND entry_id IN (?)', category.id, entries_for_category])
      return items_for_category.sum(&:amount)
  end
end
