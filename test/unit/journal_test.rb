require 'test_helper'

class JournalTest < ActiveSupport::TestCase
  fixtures :journal_types
  fixtures :journals

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
end
