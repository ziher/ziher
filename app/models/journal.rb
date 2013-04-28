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
    return "Journal(#{self.id}, #{self.journal_type}, #{self.year}, #{self.unit}, #{self.is_open ? 'open' : 'closed'}, #{initial_balance})"
  end

  # calculates balance of previous year's journal and sets it as this journal's initial balance
  def set_initial_balance
    previous = Journal.find_previous_for_type(self.journal_type, self.year-1)
    if previous
      previous_balance = previous.initial_balance + previous.get_income_sum - previous.get_expense_sum
      self.initial_balance = previous_balance
    else
      self.initial_balance = 0
    end
  end

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
    sum = 0
    self.find_items_by_category(category).each do |item|
      if item.amount
        sum += item.amount
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

  def find_next_year_journal
    return Journal.first(:conditions => {:year => self.year + 1, :unit_id => self.unit_id, :journal_type_id => self.journal_type.id})
  end

  # Returns one journal of given year and type, or nil if not found
  def Journal.find_by_year_and_type(year, type)
    found = Journal.where(:year => year, :journal_type_id => type.id)
    if found
      return found[0]
    end
  end

  def Journal.get_default(type, user)
    journals = Journal.find_by_type_and_user(type, user).first
  end

  # Returns all journals of the specified type that the specified user has access to.
  def Journal.find_by_type_and_user(type, user)
    journals = Journal.find_by_sql(["with recursive G as (
  select group_id, subgroup_id
    from subgroups
      where group_id in (select gus.group_id from groups_users gus where gus.user_id = :user_id)
  union all
  select subg.group_id, subg.subgroup_id
    from subgroups subg
      join G on G.subgroup_id = subg.group_id
)
select *
  from journals j
    where j.journal_type_id = :journal_type_id
      and (j.unit_id in (select uus.unit_id from units_users uus where uus.user_id = :user_id)
        or j.unit_id in (select gu.unit_id from groups_units gu inner join groups_users gus on gus.group_id = gu.group_id where gus.user_id = :user_id)
        or j.unit_id in (select gu.unit_id from groups_units gu where group_id in (select group_id from G union select subgroup_id from G)))", 
      { :journal_type_id => type.id, :user_id => user.id }])
  end

  # Returns journal for current (or latest) year, of given journal type
  def Journal.find_current_for_type(type)
    journal = Journal.find_previous_for_type(type, Time.now.year)
  end

  def Journal.find_previous_for_type(type, year)
    journal = Journal.where("journal_type_id = ? AND year <= ?", type.id, year).order("year DESC").first
  end

  private
  def add_error_for_duplicated_type
    errors[:journal_type] = I18n.t :journal_for_this_year_and_type_already_exists, :year => self.year, :type => self.journal_type.name, :scope => :journal
  end
end
