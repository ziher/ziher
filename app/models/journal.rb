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
    return "Journal(#{self.id}, #{self.journal_type}, #{self.year}, #{self.unit.name}, #{self.is_open ? 'open' : 'closed'}, #{initial_balance}, #{initial_balance_one_percent})"
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
    Category.find_all_by_is_expense(true).each do |category|
      sum += get_sum_for_category(category)
    end
    return sum
  end

  # returns sum of all one percent expense items
  def get_expense_one_percent_sum
    sum = 0
    Category.find_all_by_is_expense(true).each do |category|
      sum += get_sum_one_percent_for_category(category)
    end
    return sum
  end

  # returns sum of all income items
  def get_income_sum
    sum = 0
    Category.find_all_by_is_expense(false).each do |category|
      sum += get_sum_for_category(category)
    end
    return sum
  end

  # returns sum of all one percent income items
  def get_income_sum_one_percent
    sum = 0
    Category.find_all_by_is_expense(false).each do |category|
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
      items += entry.items.find_all_by_category_id(category.id)
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
  def Journal.get_default(type, user)
    journals = Journal.find_by_type_and_user(type, user).first
  end

  # Returns all journals of the specified type that the specified user has access to.
  # Journals are ordered by year, starting from newest
  def Journal.find_by_type_and_user(type, user)
    journals = Journal.where(:journal_type_id => type.id, :unit_id => Unit.find_by_user(user).map { |u| u.id }).order("year DESC")
  end

  # Returns journal for current (or latest) year, of given journal type
  def Journal.find_current_for_type(unit, type)
    journal = Journal.find_previous_for_type(unit, type, Time.now.year)
  end

  def Journal.find_previous_for_type(unit, type, year)
    journal = Journal.where("unit_id = ? AND journal_type_id = ? AND year <= ?", unit.id, type.id, year).order("year DESC").first
  end

  def find_all_years()
    years = Journal.where("journal_type_id = ? AND unit_id = ?", self.journal_type.id, self.unit.id)
  end

  private
  def add_error_for_duplicated_type
    errors[:journal_type] = I18n.t :journal_for_this_year_and_type_already_exists, :year => self.year, :type => self.journal_type.name, :scope => :journal
  end
end
