class Category < ApplicationRecord
  acts_as_list(top_of_list: 0)
  default_scope { order('position ASC')}
  audited

  has_many :items

  belongs_to :grant, optional: true

  validates :year, :presence => {:message => "Kategoria musi byc przypisana do roku"}

  validate :cannot_have_same_grant_twice_for_same_year
  validate :cannot_have_multiple_one_percent_categories_in_one_year

  before_destroy :check_category_usage

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

  def Category.create_income_from_grant_for_year(year, grant)
    category = Category.new
    category.is_expense = false
    category.name = grant.name
    category.year = year
    category.grant_id = grant.id
    category.save

    return category
  end

  def Category.find_grants_by_year(year)
    Category.where(year: year).where.not(grant_id: nil)
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
        errors.add(:category, "Tylko jedna kategoria w roku moze byc kategoria typu 1,5%")
      end
    end
  end

  def cannot_have_same_grant_twice_for_same_year
    if self.grant_id.present? then
      if Category.where(year: self.year, grant_id: self.grant_id).present? then
        errors.add(:category, "dotacja może mieć tylko jedną kategorię w danym roku")
      end
    end
  end

  def there_are_no_entries_with_self_category
    if not all_items_blank
      items_to_show = 10

      errors.add(:category, "Istnieją wpisy dla podanej kategorii:")

      category_items = self.items.select{|item| not item.amount.blank?}
      category_items.first(items_to_show).each do |item|
        entry = Entry.find(item.entry.id)

        errors.add(:category, entry.link_to_edit)
      end
      if category_items.count > items_to_show
        errors.add(:category, "... i inne, razem #{category_items.count} wpisów.")
      end
    end

    self.items.destroy_all
  end

  def there_are_no_items_with_self_grant
    if from_grant
      items_to_check = Item.includes(:grants).joins(:item_grants).where(category_id: self.id, item_grants: {grant_id: self.grant_id})

      if not items_to_check.blank?
        items_to_check.each do |item|
          errors.add(:category, "istnieje wpis #{item.id}")
        end

        # throw(:abort)
      end
    end
  end

  def there_are_no_item_grants_in_other_categories_when_disabling_grant
    if from_grant

      item_grants_errors = Array.new
      entries_to_check = Array.new

      items_to_show = 10

      Category.where(year: self.year).each do |cat|
        items_to_check = Item.get_by_category_and_grant(cat.id, self.grant_id)

        if not items_to_check.blank?
          entries_to_check << items_to_check.includes(:entry).map(&:entry)
        end
      end

      entries_to_check = entries_to_check.flatten.uniq

      entries_to_check.each do |entry|
        item_grants_errors << entry.link_to_edit
      end

      if not item_grants_errors.empty?
        errors.add(:category, "Istnieją wpisy dla podanej dotacji:")
        errors.add(:category, item_grants_errors.first(items_to_show))

        if item_grants_errors.count > items_to_show
          errors.add(:category, "... i inne, razem #{item_grants_errors.count} wpisów.")
        end
      end
    end
  end

  def check_category_usage
    there_are_no_entries_with_self_category
    there_are_no_items_with_self_grant
    there_are_no_item_grants_in_other_categories_when_disabling_grant

    if not errors[:category].empty?
      throw(:abort)
    end
  end

  def all_items_blank
    return self.items.all? {|item| item.amount.blank? }
  end

  def from_grant
    return self.grant_id.present?
  end

end
