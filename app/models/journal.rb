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

  after_save :recalculate_next_initial_balances
  after_destroy :recalculate_next_initial_balances

  # returns a user-friendly string representation
  def to_s
    return "Journal(id:#{self.id}, type:#{self.journal_type}, year:#{self.year}, unit:#{self.unit.name}, open:#{self.is_open ? 'open' : 'closed'}, balance:#{initial_balance}, balance1%:#{initial_balance_one_percent}, blocked_to:#{self.blocked_to})"
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
  def get_sum_for_category(category, to_date = end_of_year)
    get_category_sum_for(:amount, category, to_date)
  end

  # returns sum one percent of all entries in this journal for given category
  def get_sum_one_percent_for_category(category, to_date = end_of_year)
    get_category_sum_for(:amount_one_percent, category, to_date)
  end

  def get_category_sum_for(summable, category, to_date)
    entries_to_date = self.entries.select { |entry| entry.date <= to_date}
    Item.where(:entry => entries_to_date, :category => category).sum(summable)
  end

  # returns sum of all expense entries
  def get_expense_sum(to_date = end_of_year)
    sum = 0
    Category.where(:year => self.year, :is_expense => true).each do |category|
      sum += get_sum_for_category(category, to_date)
    end
    return sum
  end

  # returns sum of all one percent expense entries
  def get_expense_sum_one_percent(to_date = end_of_year)
    sum = 0
    Category.where(:year => self.year, :is_expense => true).each do |category|
      sum += get_sum_one_percent_for_category(category, to_date)
    end
    return sum
  end

  # returns sum of all income entries
  def get_income_sum(to_date = end_of_year)
    sum = 0
    Category.where(:year => self.year, :is_expense => false).each do |category|
      sum += get_sum_for_category(category, to_date)
    end
    return sum
  end

  # returns sum of all one percent income entries
  def get_income_sum_one_percent(to_date = end_of_year)
    sum = 0
    Category.where(:year => self.year, :is_expense => false, :is_one_percent => true).each do |category|
      sum += get_sum_one_percent_for_category(category, to_date)
    end
    return sum
  end

  def get_balance(to_date = end_of_year)
    return self.initial_balance + get_income_sum(to_date) - get_expense_sum(to_date)

  end

  def get_final_balance
    return get_balance(end_of_year)
  end

  def get_balance_one_percent(to_date = end_of_year)
    return self.initial_balance_one_percent + get_income_sum_one_percent - get_expense_sum_one_percent
  end

  def get_final_balance_one_percent
    return get_balance_one_percent(end_of_year)
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
    unit = Unit.get_default_unit(user, unit_id)

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
        journal_blocked_to = nil
      else
        journal_open = false
        journal_blocked_to = Journal.end_of_year(journal_year)
      end

      journal = Journal.create!(:journal_type_id => type.id, :unit_id => unit.id, :year => journal_year, :is_open => journal_open, :blocked_to => journal_blocked_to)
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
      journal = Journal.create!(:journal_type_id => type_id, :unit_id => unit_id, :year => previous_year, :is_open => false, :blocked_to => Journal.end_of_year(previous_year))
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
    Journal.create!(:journal_type_id => type_id, :unit_id => unit_id, :year => Time.now.year, :is_open => true, :blocked_to => nil)
  end

  def Journal.find_all_years
    Journal.all.map { |journal| journal.year}.uniq.sort
  end

  def Journal.find_old_open(older_than)
    journal_years_column = Journal.arel_table[:year]
    journal_years_older_than_current = journal_years_column.lt(older_than)
    return Journal.where(journal_years_older_than_current).order("year").select {|journal| journal.is_not_blocked() }
  end

  def Journal.find_open_by_year(year)
    return Journal.where(:year => year).select {|journal| journal.is_not_blocked() }
  end

  def Journal.close_old_open(older_than)
    Journal.find_old_open(older_than).each {|journal| journal.close}
  end

  def Journal.open_all_by_year(year)
    Journal.where(:year => year).each {|journal| journal.open}
  end

  def Journal.close_all_by_year(year, blocked_to = Journal.end_of_year(year))
    Journal.where(:year => year).each {|journal| journal.close(blocked_to)}
  end

  def journals_for_linked_entry
    return Journal.where("year = ? AND id <> ?", self.year, self.id)
  end

  def verify_balance_one_percent_not_less_than_zero(to_date = end_of_year)
    if self.get_balance_one_percent(to_date) < 0
      errors[:one_percent] << I18n.t(:sum_one_percent_must_not_be_less_than_zero, :sum_one_percent => get_balance_one_percent(to_date), :scope => :journal)
      return false
    else
      return true
    end
  end

  def verify_balance_one_percent_no_more_than_sum(to_date = end_of_year)
    if self.get_balance_one_percent(to_date) == 0 or self.get_balance_one_percent(to_date) <= self.get_balance(to_date)
      return true
    end

    if self.get_balance(to_date) < 0
      errors[:one_percent] << I18n.t(:sum_one_percent_negative_with_one_percent_left, :sum_one_percent => get_balance_one_percent(to_date), :sum => get_balance(to_date), :scope => :journal)
    else
      errors[:one_percent] << I18n.t(:sum_one_percent_must_not_be_more_than_sum, :sum_one_percent => get_balance_one_percent(to_date), :sum => get_balance(to_date), :scope => :journal)
    end
    return false
  end

  def verify_entries(to_date = end_of_year)
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

  def verify_journal(blocked_to = end_of_year)
    result = true
    result = false unless verify_balance_one_percent_not_less_than_zero(blocked_to)
    result = false unless verify_balance_one_percent_no_more_than_sum(blocked_to)
    result = false unless verify_entries(blocked_to)
    result = false unless verify_inventory
    return result
  end

  def close(blocked_to = end_of_year)

    return false unless verify_block_date(blocked_to) and verify_journal(blocked_to)

    blocked_to == end_of_year ? self.is_open = false : self.is_open = true
    self.blocked_to = blocked_to
    return self.save!
  end

  def is_not_blocked(as_of_day = end_of_year)
    if self.blocked_to.nil?
      return false if not self.is_open?
      return true
    end

    return self.blocked_to < as_of_day
  end

  def open
    self.is_open=true
    self.blocked_to=nil

    return self.save!
  end

  def opened_from_info
    case self.blocked_to
    when nil
      return "Książka zamknięta" if not self.is_open?
      return "Książka otwarta"
    when end_of_year
      return "Książka zamknięta"
    else
      open_from = self.blocked_to + 1.day
      return "Książka otwarta od #{open_from}"
    end
  end

  def blocked_to_info
    case self.blocked_to
    when nil
      return "Książka zamknięta" if not self.is_open?
      return "Książka otwarta"
    when end_of_year
      return "Książka zamknięta"
    else
      return "Książka zamknięta do #{self.blocked_to} (włącznie)"
    end
  end

  def blocked_to_short_info
    case self.blocked_to
    when nil
      return "Zamknięta" if not self.is_open?
      return "Otwarta"
    when end_of_year
      return "Zamknięta"
    else
      return "Do #{self.blocked_to}"
    end
  end

  def set_blocked_to!
    self.blocked_to = Date.new(self.year).end_of_year
    return save!
  end


  def recalculate_next_initial_balances
    next_journal = self.find_next_year_journal
    while next_journal
      next_journal.set_initial_balance
      next_journal.save!

      next_journal = next_journal.find_next_year_journal
    end
  end

  private
  def add_error_for_duplicated_type
    errors[:journal_type] << I18n.t(:journal_for_this_year_and_type_already_exists, :year => self.year, :type => self.journal_type.name, :scope => :journal)
  end

  def Journal.end_of_year(year)
    return Date.new(year).end_of_year
  end

  def end_of_year
    return Date.new(self.year).end_of_year
  end

  def verify_block_date(date)
    if date.year != self.year or date.blank? or not date.is_a?(Date)
      errors[:blocked_to] << "Błędna data zamknięcia książki"
      return false
    end

    return true
  end
end