require 'test_helper'

class UnitTest < ActiveSupport::TestCase
  test "find by user" do
    units = Unit.find_by_user(users(:admin))
    assert_equal(Unit.all.count, units.count)

    units = Unit.find_by_user(users(:master_1zgm))
    assert_equal(1, units.count)

    units = Unit.find_by_user(users(:master_zg_m))
    assert_equal(2, units.count)

    units = Unit.find_by_user(users(:master_p_f))
    assert_equal(4, units.count)
    
    units = Unit.find_by_user(users(:master_p))
    assert_equal(8, units.count)
  end

  test "should return all journal years including current" do
    #given
    year_2025 = Time.parse('2025-05-05')
    pretend_now_is(year_2025) do
      troop_1zgm = units(:troop_1zgm)
      finance_type = journal_types(:finance)

      #when
      years = troop_1zgm.find_journal_years(finance_type).to_set

      #then
      expected_years = troop_1zgm.journals.map{|journal| journal.year}.uniq.to_set
      expected_years << Time.now.year

      assert_equal expected_years, years
    end
  end

  test "should return journal years sorted" do
    #given
    year_2005 = Time.parse('2005-05-05')
    pretend_now_is(year_2005) do
      troop_1zgm = units(:troop_1zgm)
      finance_type = journal_types(:finance)

      #when
      years = troop_1zgm.find_journal_years(finance_type)

      #then
      assert_equal years.sort, years
    end
  end

  test "should not return duplicate years" do
    #given
    year_2012 = Time.parse('2012-05-05')
    pretend_now_is(year_2012) do
      troop_1zgm = units(:troop_1zgm)
      finance_type = journal_types(:finance)

      #when
      years = troop_1zgm.find_journal_years(finance_type)

      #then
      assert_equal years.uniq, years
    end
  end

end
