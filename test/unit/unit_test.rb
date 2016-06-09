require 'test_helper'

class UnitTest < ActiveSupport::TestCase
  test "find by user" do
    units = Unit.find_by_user(users(:admin))
    assert_equal(Unit.all.count, units.count)

    units = Unit.find_by_user(users(:master_1zgm))
    assert_equal(1, units.count)

    units = Unit.find_by_user(users(:master_2zgm))
    assert_equal(1, units.count)

    units = Unit.find_by_user(users(:master_zg_m))
    assert_equal(2, units.count)

    units = Unit.find_by_user(users(:master_zg))
    assert_equal(4, units.count)

    units = Unit.find_by_user(users(:master_p_f))
    assert_equal(4, units.count)
    
    units = Unit.find_by_user(users(:master_p))
    assert_equal(8, units.count)
  end

  test "should find only units where group user has access to" do
    #given
    user = users(:user_zg)
    units = Unit.find_by_user(user)

    #when

    #then
    assert_equal(1, units.count)
  end

  test "should return all journal years including current" do
    #given
    year_2025 = Time.parse('2025-05-05')
    Timecop.travel(year_2025) do
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
    Timecop.travel(year_2005) do
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
    Timecop.travel(year_2012) do
      troop_1zgm = units(:troop_1zgm)
      finance_type = journal_types(:finance)

      #when
      years = troop_1zgm.find_journal_years(finance_type)

      #then
      assert_equal years.uniq, years
    end
  end

  test "should return finance balance" do
    #given
    troop_1zgm = units(:troop_1zgm)
    finance_2012 = journals(:finance_2012)

    #when
    balance = troop_1zgm.initial_finance_balance(2012)

    #then
    assert_equal finance_2012.initial_balance, balance
  end

  test "should return nil finance balance when unit has no finance journal" do
    #given
    troop_1dwf = units(:troop_1dwf)

    #when
    balance = troop_1dwf.initial_finance_balance(2012)

    #then
    assert_equal nil, balance
  end

  test "should return finance balance one percent" do
    #given
    troop_1zgm = units(:troop_1zgm)
    finance_2012 = journals(:finance_2012)

    #when
    balance = troop_1zgm.initial_finance_balance_one_percent(2012)

    #then
    assert_equal finance_2012.initial_balance_one_percent, balance
  end

  test "should return nil finance balance one percent when unit has no finance journal" do
    #given
    troop_1dwf = units(:troop_1dwf)

    #when
    balance = troop_1dwf.initial_finance_balance_one_percent(2012)

    #then
    assert_equal nil, balance
  end

  test "should return bank balance" do
    #given
    troop_1zgm = units(:troop_1zgm)
    bank_2012 = journals(:bank_2012)

    #when
    balance = troop_1zgm.initial_bank_balance(2012)

    #then
    assert_equal bank_2012.initial_balance, balance
  end

  test "should return nil bank balance when unit has no bank journal" do
    #given
    troop_1dwf = units(:troop_1dwf)

    #when
    balance = troop_1dwf.initial_bank_balance(2012)

    #then
    assert_equal nil, balance
  end

  test "should return bank balance one percent" do
    #given
    troop_1zgm = units(:troop_1zgm)
    bank_2012 = journals(:bank_2012)

    #when
    balance = troop_1zgm.initial_bank_balance_one_percent(2012)

    #then
    assert_equal bank_2012.initial_balance_one_percent, balance
  end

  test "should return nil bank balance one percent when unit has no bank journal" do
    #given
    troop_1dwf = units(:troop_1dwf)

    #when
    balance = troop_1dwf.initial_bank_balance_one_percent(2012)

    #then
    assert_equal nil, balance
  end
end
