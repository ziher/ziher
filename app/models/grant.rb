class Grant < ApplicationRecord
  audited

  validates :name, presence: true
  validates :description, presence: true

  has_many :item_grants, dependent: :destroy
  has_many :items, through: :item_grants
  accepts_nested_attributes_for :item_grants

  has_many :journal_grants, dependent: :destroy
  has_many :journals, through: :journal_grants
  accepts_nested_attributes_for :journal_grants

  has_many :categories

  before_destroy :there_are_no_linked_categories

  def category_exists?(year)
    Category.where(year: year, grant_id: self.id).present?
  end

  def create_income_category_for_year(year)
    category = Category.create_income_from_grant_for_year(year, self)

    unless category.persisted?
      self.errors.copy!(category.errors)
    end

    return category.persisted?
  end

  def delete_income_category_for_year(year)
    result = Category.where(year: year, grant_id: self.id).destroy_all

    return result
  end

  def there_are_no_linked_categories
    categories = Category.where(grant_id: self.id)

    if categories.present? then
      categories_to_show = 10

      errors.add(:base, "Błąd usuwania - dotacja włączona w poniższych latach:")

      categories.first(categories_to_show).each do |category|
        errors.add(:base, category.year)
      end

      if categories.count > categories_to_show
        errors.add(:base, "... i inne, razem #{categories.count} kategorii.")
      end

      throw(:abort)
    end
  end

  def get_category_by_year(year)
    Category.where(year: year, grant_id: self.id)
  end

  def Grant.get_by_year(year)
    Grant.includes(:categories).where(categories: {year: year})
  end
end
