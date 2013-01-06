require 'test_helper'

class JournalTest < ActiveSupport::TestCase
  fixtures :journal_types

  test "should prevent creating two journals of the same type for the same year" do
    assert_raise(ActiveRecord::RecordInvalid){
      journal = Journal.create!(:journal_type => journal_types(:one), :year => 2012)
    }
  end

  test "should save two journals of the same type for different years" do
    journal = Journal.create!(:journal_type => journal_types(:one), :year => 2013)
    assert_not_nil journal
  end

  test "should prevent saving without type" do
    assert_raise(ActiveRecord::RecordInvalid){
      journal = Journal.create!
    }
  end

  test "should save journal with type" do
    journal = Journal.create!(:journal_type => journal_types(:one))
    assert_not_nil journal
  end
end
