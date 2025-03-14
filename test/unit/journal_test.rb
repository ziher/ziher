require 'test_helper'

class JournalTest < ActiveSupport::TestCase
  fixtures :journal_types
  fixtures :journals
  fixtures :categories
  fixtures :units
  
  # TODO: should create opened journal for current year
  # TODO: should create closed journal for not current year

  test "should prevent creating two journals of the same type for the same year" do
    assert_raise(ActiveRecord::RecordInvalid){
      journal = Journal.create!(:journal_type => journal_types(:finance), :year => 2012, :unit => units(:troop_1zgm))
    }
  end

  test "should save two journals of the same type for different years" do
    journal = Journal.create!(:journal_type => journal_types(:finance), :year => 2013, :unit => units(:troop_1zgm))
    assert_not_nil journal
  end

  test "should save journal after it was created" do
    journal = Journal.create!(:journal_type => journal_types(:finance), :year => 2013, :unit => units(:troop_1zgm))
    journal.save!
    assert_not_nil journal
  end

  test "should prevent saving without type" do
    assert_raise(ActiveRecord::RecordInvalid){
      journal = Journal.create!(:unit => units(:troop_1zgm))
    }
  end

  test "should prevent closing when final sum one percent is less than zero" do
    #given
    journal = journals(:finance_2012)
    journal.initial_balance = 0
    journal.initial_balance_one_percent = 0

    income_item1 = Item.new(:amount => 1, :amount_one_percent => 0, :category => categories(:two))
    income_item2 = Item.new(:amount => 1, :amount_one_percent => 1, :category => categories(:two_one_percent))
    income_entry = Entry.new(:items => [income_item1, income_item2], :journal_id => journal.id, :date => "2012-01-01", :name => "name", :document_number => "document number")
    income_entry.save!

    expense_item = Item.new(:amount => 2, :amount_one_percent => 1.01, :category => categories(:five))
    expense_entry = Entry.new(:items => [expense_item], :journal_id => journal.id, :date => "2012-01-01", :name => "name", :document_number => "document number")
    expense_entry.save!

    #when
    journal.entries = [income_entry, expense_entry]

    #then
    assert !(journal.close)
  end

  test "should allow closing when final sum one percent equals zero" do
    #given
    journal = journals(:finance_2012)
    journal.initial_balance = 0
    journal.entries = []

    #when
    journal.initial_balance_one_percent = 0

    #then
    assert journal.close
  end

  test "should prevent closing when final sum one percent is bigger than final sum" do
    #given
    journal = journals(:finance_2012)
    journal.initial_balance = 0
    journal.initial_balance_one_percent = 0

    income_item = Item.new(:amount => 1, :amount_one_percent => 1, :category => categories(:two_one_percent))
    income_entry = Entry.new(:items => [income_item], :journal_id => journal.id, :date => "2012-01-01", :name => "name", :document_number => "document number")
    income_entry.save!

    expense_item = Item.new(:amount => 1, :amount_one_percent => 0.99, :category => categories(:five))
    expense_entry = Entry.new(:items => [expense_item], :journal_id => journal.id, :date => "2012-01-01", :name => "name", :document_number => "document number")
    expense_entry.save!

    #when
    journal.entries = [income_entry, expense_entry]

    #then
    assert !(journal.close)
  end

  test "should save journal with type" do
    journal = Journal.create!(:journal_type => journal_types(:finance), :year => 2013, :unit => units(:troop_1zgm))
    assert_not_nil journal
  end

  test "should find one journal by unit and year and type" do
    found = Journal.find_by_unit_and_year_and_type(units(:troop_1zgm), 2012, journal_types(:finance))
    assert_instance_of Journal, found
  end

  test "should return nil when not found by unit and year and type" do
    found = Journal.find_by_unit_and_year_and_type(units(:troop_1zgm), 2014, journal_types(:finance))
    assert_nil found
  end

  test "should get default journal for current year" do
    year_2015 = Time.parse('2015-05-05')
    Timecop.travel(year_2015) do
      journal_2015 = journals(:finance_2015)
      assert_equal journal_2015, Journal.get_default(journal_types(:finance), users(:master_1zgm))
    end
  end

  test "should not get journal for not own units" do
    journal = Journal.get_default(journal_types(:finance), users(:master_1zgm), units(:troop_2dwf).id, 2018)
    assert_not journal
  end

  test "should count sum for category" do
    journal = journals(:finance_2012)
    category = categories(:one)

    assert_equal count_sum_for_category(journal, category), journal.get_sum_for_category(category)
  end

  test "should count expense sum" do
    journal = journals(:finance_2012)

    expected_sum = 0
    Category.all.each do |category|
      if category.is_expense
        expected_sum += count_sum_for_category(journal, category)
      end
    end

    assert_equal expected_sum, journal.get_expense_sum
  end

  test "should count expense sum one percent" do
    #given
    journal = journals(:finance_2012)

    #when
    expected_sum = 0
    Category.all.each do |category|
      if category.is_expense
        expected_sum += count_sum_one_percent_for_category(journal, category)
      end
    end

    #then
    assert_not_equal 0, expected_sum
    assert_equal expected_sum, journal.get_expense_sum_one_percent
  end

  test "should count income sum" do
    journal = journals(:finance_2012)

    expected_sum = 0
    Category.all.each do |category|
      unless category.is_expense
        expected_sum += count_sum_for_category(journal, category)
      end
    end

    assert_equal expected_sum, journal.get_income_sum
  end

  test "should count income sum one percent" do
    #given
    journal = journals(:finance_2012)
    expected_amount = 0

    #when
    journal.entries.each do |entry|
      expected_amount += entry.items.select{|item| item.category.is_one_percent}.sum(&:amount_one_percent)
    end

    #then
    assert_not_equal 0, expected_amount
    assert_equal expected_amount, journal.get_income_sum_one_percent
    assert_not_equal journal.get_income_sum_one_percent, journal.get_expense_sum_one_percent
  end

  test "should have initial balance" do
    journal = journals(:finance_2012)
    assert_not_nil journal.initial_balance
  end

  test "should count initial balance" do
    #given
    previous = journals(:finance_2012)
    balance = previous.initial_balance + previous.get_income_sum - previous.get_expense_sum

    #when
    new_journal = Journal.create!(:year => 2013, :journal_type => journal_types(:finance), :unit => units(:troop_1zgm))

    #then
    assert_equal balance, new_journal.initial_balance
  end

  test "should set initial balance to zero when there is no previous journal" do
    #when
    new_journal = Journal.create!(:year => 2001, :journal_type => journal_types(:finance), :unit => units(:troop_1zgm))

    #then
    assert_equal 0, new_journal.initial_balance
  end

  test "should count initial balance when last journal is not previous year" do
    #given
    previous = journals(:finance_2012)
    balance = previous.initial_balance + previous.get_income_sum - previous.get_expense_sum

    #when
    new_journal = Journal.create(:year => 2014, :journal_type => journal_types(:finance), :unit => units(:troop_1zgm))

    #then
    assert_equal balance, new_journal.initial_balance
  end

  test "should require year" do
    #given
    journal = journals(:finance_2012)

    #when
    journal.year = nil

    #then
    assert_raise(ActiveRecord::RecordInvalid){
      journal.save!
    }
  end

  test "should recalculate balance when adding entry" do
    #given
    #two open journals
    earlier = journals(:finance_2011)
    later = journals(:finance_2012)
    balance_before = later.initial_balance

    difference = 20

    #when
    #an entry is added to earlier journal
    item = Item.new(:amount => difference, :category => categories(:income_2011_2))
    entry = Entry.new(:items => [item], :journal_id => earlier.id, :date => "2011-01-01", :name => "name", :document_number => "document number")
    entry.save!

    #then
    #later journal's balance is recalculated
    later.reload
    balance_after = later.initial_balance

    assert_equal(balance_before + difference, balance_after)
  end

  test "should recalculate balance when editing entry" do
    #given
    #two open journals
    earlier = journals(:finance_2011)
    later = journals(:finance_2012)
    balance_before = later.initial_balance
    entry = earlier.entries.first
    item = entry.items.first

    difference = 15

    #when
    item.amount += difference
    item.save!

    #then
    entry.save!
    later.reload
    balance_after = later.initial_balance

    assert_equal(balance_before + difference, balance_after)
  end

  test "should recalculate balance when deleting entry" do
    #given
    #two open journals
    earlier = journals(:finance_2011)
    later = journals(:finance_2012)
    balance_before = later.initial_balance
    entry = earlier.entries.first

    amount = entry.sum

    #when
    entry.destroy

    #then
    later.reload
    balance_after = later.initial_balance

    assert_equal(balance_before - amount, balance_after)
  end

  test "should return only current year for linked entry" do
    #given
    journal = journals(:finance_2012)

    #then
    journal.journals_for_linked_entry.each do |linked_journal|
      assert(linked_journal.year == journal.year)
    end
  end

  test "should not return current journal for linked entry" do
    #given
    journal = journals(:finance_2012)

    #then
    assert(!journal.journals_for_linked_entry.include?(journal))
  end

  test "should create journal" do
    #given
    journal = journals(:finance_2012)
    unit_id = journal.unit.id
    type_id = journal.journal_type_id
    current_year = Time.now.year
    Journal.where(year: current_year, unit_id: unit_id).destroy_all

    #when
    new_journal = Journal.create_for_current_year(type_id, unit_id)

    #then
    assert_equal current_year, new_journal.year
    assert new_journal.is_not_blocked
  end

  test "#get_sum_for_grant_in_category" do
    grant = grants(:one)
    category = categories(:five)
    journal = journals(:finance_2012)

    result = journal.get_sum_for_grant_in_category(grant, category)
    assert_equal result, 19.98
  end

  private

  def count_sum_for_category(journal, category)
      entries_for_category = Entry.where(journal: journal).map(&:id)
      items_for_category = Item.where(['category_id = ? AND entry_id IN (?)', category.id, entries_for_category])
      return items_for_category.to_a.sum(&:amount)
  end

  def count_sum_one_percent_for_category(journal, category)
    entries_for_category = Entry.where(journal: journal).map(&:id)
    items_for_category = Item.where(['category_id = ? AND entry_id IN (?) and amount_one_percent IS NOT NULL', category.id, entries_for_category])
    return items_for_category.to_a.sum(&:amount_one_percent)
  end
end
