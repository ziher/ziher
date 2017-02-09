class Category < ActiveRecord::Base
  acts_as_list(top_of_list: 0)
  default_scope { order('position ASC')}

  validates :year, :presence => {:message => "Kategoria musi byc przypisana do roku"}

  validate :cannot_have_multiple_one_percent_categories_in_one_year

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
end
