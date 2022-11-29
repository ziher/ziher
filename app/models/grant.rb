class Grant < ApplicationRecord
  audited

  validates :name, presence: true
  validates :description, presence: true

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
end
