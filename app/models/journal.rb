class Journal < ActiveRecord::Base
  belongs_to :journal_type
  has_many :entries

  validates :journal_type, :presence => true
  validate :cannot_have_duplicated_type

  def cannot_have_duplicated_type
    if self.journal_type
      found = Journal.find_by_year_and_type(self.year, self.journal_type)
      if found and found != self
        add_error_for_duplicated_type
      end
    end
  end

  # returns sum of all items in this journal in given category
  def get_sum_for_category(category)
    return self.find_items_by_category(category).each.sum(&:amount)
  end

  # returns sum of all expense items
  def get_expense_sum
    sum = 0
    Category.find_all_by_is_expense(true).each do |category|
      sum += get_sum_for_category(category)
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

  def find_items_by_category(category)
    items = []
    self.entries.each do |entry|
      items += entry.items.find_all_by_category_id(category.id)
    end
    return items
  end

  # Returns one journal of given year and type, or nil if not found
  def Journal.find_by_year_and_type(year, type)
    found = Journal.where(:year => year, :journal_type_id => type.id)
    if found
      return found[0]
    end
  end

  # Returns journal for current (or latest) year, of default journal type,
  # or first found journal if default journal type is not specified
  def Journal.get_default
    default_type = JournalType.where(:is_default => true).first
    if not default_type
      return Journal.first
    end
    journal = Journal.find_current_for_type(default_type)
  end

  # Returns journal for current (or latest) year, of given journal type
  def Journal.find_current_for_type(type)
    journal = Journal.where("journal_type_id = ? AND year <= ?", type.id, Time.now.year).order("year DESC").first
  end

  private
  def add_error_for_duplicated_type
    errors[:journal_type] = I18n.t :journal_for_this_year_and_type_already_exists, :year => self.year, :type => self.journal_type.name, :scope => :journal
  end
end
