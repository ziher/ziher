class Journal < ActiveRecord::Base
  audited

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
      previous_balance_one_percent = previous.initial_balance_one_percent + previous.get_income_sum_one_percent - previous.get_expense_sum_one_percent

      self.initial_balance = previous_balance
      self.initial_balance_one_percent = previous_balance_one_percent
    end
  end

  def cannot_have_duplicated_type
    if self.journal_type
      found = Journal.find_by_unit_and_year_and_type(self.unit, self.year, self.journal_type)
      if found && found != self
        add_error_for_duplicated_type
      end
    end
  end

  # returns sum of all entries in this journal for given category
  def get_sum_for_category(category)
    Item.where(:entry => self.entries, :category => category).sum(:amount)
  end

  # returns sum one percent of all entries in this journal for given category
  def get_sum_one_percent_for_category(category)
    Item.where(:entry => self.entries, :category => category).sum(:amount_one_percent)
  end

  # returns sum of all expense entries
  def get_expense_sum
    sum = 0
    Category.where(:year => self.year, :is_expense => true).each do |category|
      sum += get_sum_for_category(category)
    end
    return sum
  end

  # returns sum of all one percent expense entries
  def get_expense_sum_one_percent
    sum = 0
    Category.where(:year => self.year, :is_expense => true).each do |category|
      sum += get_sum_one_percent_for_category(category)
    end
    return sum
  end

  # returns sum of all income entries
  def get_income_sum
    sum = 0
    Category.where(:year => self.year, :is_expense => false).each do |category|
      sum += get_sum_for_category(category)
    end
    return sum
  end

  # returns sum of all one percent income entries
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
    return self.initial_balance_one_percent + get_income_sum_one_percent - get_expense_sum_one_percent
  end

  def find_next_year_journal
    return Journal.where(year: self.year + 1, unit_id: self.unit_id, journal_type_id: self.journal_type.id).first
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
    user_units = Unit.find_by_user(user)

    if unit_id.nil?
      unit = user_units.first
    else
      if unit_id.in? user_units.map { |unit| unit.id }
        unit = user_units.find{ |unit| unit.id == unit_id }
      end
    end

    if unit.nil?
      return
    end

    journal_year = year || Time.now.year

    journal = Journal.find_by_unit_and_year_and_type(unit, journal_year, type)

    # if the journal was not found it means it doesn't exist -
    # journal probably existed for the unit and year but different journal type -
    # in such case just create the open journal for the type if it's current year
    # or closed one if it's previous year
    if journal.nil?
      if journal_year == Time.now.year
        journal_open = true
      else
        journal_open = false
      end

      journal = Journal.create!(:journal_type_id => type.id, :unit_id => unit.id, :year => journal_year, :is_open => journal_open)
    end

    return journal
  end

  # Returns all journals of the specified type that the specified user has access to.
  # Journals are ordered by year, starting from newest
  def Journal.find_by_type_and_user(type, user)
    journals = Journal.where(:journal_type_id => type.id, :unit_id => Unit.find_by_user(user).map { |u| u.id }).order("year DESC")
  end

  def Journal.find_previous_for_type(unit, type, year)
    journal = Journal.where("unit_id = ? AND journal_type_id = ? AND year <= ?", unit.id, type.id, year).order("year DESC").first
  end

  # Returns journal for unit and type for previous year
  def Journal.get_previous_for_type(unit_id, type_id)
    previous_year = Time.now.year - 1
    journal = Journal.where(:journal_type_id => type_id, :unit_id => unit_id, :year => previous_year).first

    if (journal == nil)
      journal = Journal.create!(:journal_type_id => type_id, :unit_id => unit_id, :year => previous_year, :is_open => false)
    end

    return journal
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
    if self.get_final_balance_one_percent == 0 or self.get_final_balance_one_percent <= self.get_final_balance
      return true
    end

    if self.get_final_balance < 0
      errors[:one_percent] << I18n.t(:sum_one_percent_negative_with_one_percent_left, :sum_one_percent => get_final_balance_one_percent, :sum => get_final_balance, :scope => :journal)
    else
      errors[:one_percent] << I18n.t(:sum_one_percent_must_not_be_more_than_sum, :sum_one_percent => get_final_balance_one_percent, :sum => get_final_balance, :scope => :journal)
    end
    return false
  end

  def verify_entries
    result = true
    self.entries.each do |entry|
      if !entry.verify_entry
        result = false
        errors[:entry] << entry.errors.values
      end
    end
    return result
  end

  def verify_inventory
    result = true

    inventoryVerifier = InventoryEntryVerifier.new(self.unit)
    years_to_verify = [self.year]
    unless inventoryVerifier.verify(years_to_verify)
      errors[:inventory] << '<br/>' + inventoryVerifier.errors.values.join("<br/><br/>")
      result = false
    end

    return result
  end

  def verify_journal
    result = true
    result = false unless verify_final_balance_one_percent_not_less_than_zero
    result = false unless verify_final_balance_one_percent_no_more_than_sum
    result = false unless verify_entries
    result = false unless verify_inventory
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
