class Journal < ActiveRecord::Base
  belongs_to :journal_type
  belongs_to :unit
  has_many :entries

  validates :journal_type, :presence => true
  validates :unit, :presence => true
  validates :year, :presence => true
  validate :cannot_have_duplicated_type

  before_create :set_initial_balance

  # returns a user-friendly string representation
  def to_s
    return "Journal(id:#{self.id}, type:#{self.journal_type}, year:#{self.year}, unit:#{self.unit.name}, open:#{self.is_open ? 'open' : 'closed'}, balance:#{initial_balance}, balance1%:#{initial_balance_one_percent})"
  end

  # calculates balance of previous year's journal and sets it as this journal's initial balance
  def set_initial_balance
    previous = Journal.find_previous_for_type(self.unit, self.journal_type, self.year-1)
    if previous
      previous_balance = previous.initial_balance + previous.get_income_sum - previous.get_expense_sum
      previous_balance_one_percent = previous.initial_balance_one_percent + previous.get_income_sum_one_percent - previous.get_expense_one_percent_sum

      self.initial_balance = previous_balance
      self.initial_balance_one_percent = previous_balance_one_percent
    end
  end

  def cannot_have_duplicated_type
    if self.journal_type
      found = Journal.find_by_unit_and_year_and_type(self.unit, self.year, self.journal_type)
      if found and found != self
        add_error_for_duplicated_type
      end
    end
  end

  # returns sum of all items in this journal in given category
  def get_sum_for_category(category)
    sum = 0
    self.find_items_by_category(category).each do |item|
      if item.amount
        sum += item.amount
      end
    end

    return sum
  end

  # returns sum one percent of all items in this journal in given category
  def get_sum_one_percent_for_category(category)
    sum = 0
    self.find_items_by_category(category).each do |item|
      if item.amount_one_percent
        sum += item.amount_one_percent
      end
    end
    return sum
  end

  # returns sum of all expense items
  def get_expense_sum
    sum = 0
    Category.where(:year => self.year, :is_expense => true).each do |category|
      sum += get_sum_for_category(category)
    end
    return sum
  end

  # returns sum of all one percent expense items
  def get_expense_one_percent_sum
    sum = 0
    Category.where(:year => self.year, :is_expense => true).each do |category|
      sum += get_sum_one_percent_for_category(category)
    end
    return sum
  end

  # returns sum of all income items
  def get_income_sum
    sum = 0
    Category.where(:year => self.year, :is_expense => false).each do |category|
      sum += get_sum_for_category(category)
    end
    return sum
  end

  # returns sum of all one percent income items
  def get_income_sum_one_percent
    sum = 0
    Category.where(:year => self.year, :is_expense => false, :is_one_percent => true).each do |category|
      sum += get_sum_one_percent_for_category(category)
    end
    return sum
  end

  def get_final_balance
    return self.initial_balance + get_income_sum - get_expense_sum
  end

  def get_final_balance_one_percent
    return self.initial_balance_one_percent + get_income_sum_one_percent - get_expense_one_percent_sum
  end

  def find_items_by_category(category)
    items = []
    self.entries.each do |entry|
      items |= entry.items.find_all {|item| item.category == category}
    end
    return items
  end

  def find_next_year_journal
    return Journal.first(:conditions => {:year => self.year + 1, :unit_id => self.unit_id, :journal_type_id => self.journal_type.id})
  end

  # Returns one journal of given year and type, or nil if not found
  def Journal.find_by_unit_and_year_and_type(unit, year, type)
    found = Journal.where(:unit_id => unit.id, :year => year, :journal_type_id => type.id)
    if found
      return found[0]
    end
  end

  # Returns the most recent journal for given type, that the given user has access to
  def Journal.get_default(type, user, unit_id = nil, year = nil)
    journals = Journal.find_by_type_and_user(type, user)

    #if there was the unit and year passed - use them to find the proper journal
    if (unit_id != nil && year != nil)
      if journals.any?{|journal| journal.unit.id == unit_id && journal.year == year}
        return journals.find{|journal| journal.unit.id == unit_id && journal.year == year}
      else
        # if the journal was not found it means it doesn't exist -
        # journal probably existed for the unit and year but different journal type -
        # in such case just create the journal for the type
        return Journal.create!(:journal_type_id => type.id, :unit_id => unit_id, :year => year, :is_open => true)
      end
    end

    return journals.first
  end

  # Returns all journals of the specified type that the specified user has access to.
  # Journals are ordered by year, starting from newest
  def Journal.find_by_type_and_user(type, user)
    journals = Journal.where(:journal_type_id => type.id, :unit_id => Unit.find_by_user(user).map { |u| u.id }).order("year DESC")
  end

  def Journal.find_previous_for_type(unit, type, year)
    journal = Journal.where("unit_id = ? AND journal_type_id = ? AND year <= ?", unit.id, type.id, year).order("year DESC").first
  end

  # Returns journal for unit and type current year
  def Journal.get_current_for_type(unit_id, type_id)
    journal = Journal.where(:journal_type_id => type_id, :unit_id => unit_id, :year => Time.now.year).first

    # there should be always a journal for current year - if there is not just create it
    if (journal == nil)
      journal = create_for_current_year(type_id, unit_id)
    end
    return journal
  end

  # Creates a new open journal for given journal type and unit and current year.
  def Journal.create_for_current_year(type_id, unit_id)
    Journal.create!(:journal_type_id => type_id, :unit_id => unit_id, :year => Time.now.year, :is_open => true)
  end

  def Journal.find_all_years
    Journal.all.map { |journal| journal.year}.uniq.sort
  end

  def journals_for_linked_entry
    return Journal.where("year = ? AND id <> ?", self.year, self.id)
  end

  def verify_final_balance_one_percent_not_less_than_zero
    if self.get_final_balance_one_percent < 0
      errors[:one_percent] << I18n.t(:sum_one_percent_must_not_be_less_than_zero, :sum_one_percent => get_final_balance_one_percent, :scope => :journal)
      return false
    else
      return true
    end
  end

  def verify_final_balance_one_percent_no_more_than_sum
    if self.get_final_balance_one_percent > self.get_final_balance
      errors[:one_percent] << I18n.t(:sum_one_percent_must_not_be_more_than_sum, :sum_one_percent => get_final_balance_one_percent, :sum => get_final_balance, :scope => :journal)
      return false
    else
      return true
    end
  end

  def verify_journal
    result = true
    result = false unless verify_final_balance_one_percent_not_less_than_zero
    result = false unless verify_final_balance_one_percent_no_more_than_sum
    return result
  end

  def close
    if verify_journal then
      self.is_open = false
      return self.save!
    else
      return false
    end
  end

  private
  def add_error_for_duplicated_type
    errors[:journal_type] << I18n.t(:journal_for_this_year_and_type_already_exists, :year => self.year, :type => self.journal_type.name, :scope => :journal)
  end
end
