class Category < ActiveRecord::Base
  acts_as_list(top_of_list: 0)
  default_scope { order('position ASC')}
  audited

  has_many :items

  validates :year, :presence => {:message => "Kategoria musi byc przypisana do roku"}

  validate :cannot_have_multiple_one_percent_categories_in_one_year
  before_destroy :there_are_no_entries_with_self_category

  def Category.get_all_years
    years = []
    Category.find_each do |category|
      years << category.year
    end
    return years.uniq.sort
  end

  def Category.find_by_year_and_type(year, is_expense)
    Category.where(year: year, is_expense: is_expense)
  end

  def cannot_have_multiple_one_percent_categories_in_one_year
    years = []
    Category.find_each do |category|
      if category.is_one_percent then
        years << category.year
      end
    end

    if self.is_one_percent then
      if years.include?(self.year) then
        errors[:category] << "Tylko jedna kategoria w roku moze byc kategoria typu 1%"
      end
    end
  end

  def there_are_no_entries_with_self_category
    if not all_items_blank
      items_to_show = 10

      errors[:category] << "Istnieją wpisy dla podanej kategorii:"

      category_items = self.items.select{|item| not item.amount.blank?}
      category_items.first(items_to_show).each do |item|
        entry = Entry.find(item.entry.id)

        errors[:category] << entry.link_to_edit
      end
      if category_items.count > items_to_show
        errors[:category] << "... i inne, razem #{category_items.count} wpisów."
      end

      return false
    end

    self.items.destroy_all
  end

  def all_items_blank
    return self.items.all? {|item| item.amount.blank? }
  end
end
