class Entry < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :items, dependent: :destroy
  belongs_to :journal

  accepts_nested_attributes_for :items, :reject_if => :reject_empty_items

  validates :items, :presence => {:message => "Wpis musi miec przynajmniej jedna sume"}
  validates :journal, :presence => {:message => "Wpis musi byc przypisany do ksiazki"}
  validate :cannot_have_multiple_items_in_one_category
  validate :cannot_have_item_from_category_not_from_journals_year

  def get_amount_for_category(category_id)
    result = self.items.find(:first, :conditions=>{:category_id=>category_id})

    if result != nil && result.amount != nil
      return result.amount
    else
      return 0
    end
  end

  def has_category(category_id)
    existing_item = self.items.find(:first, :conditions=>{:category_id=>category_id})
    return (existing_item != nil)
  end

  def cannot_have_multiple_items_in_one_category
    categories = []
    items.each do |item|
      if item.category != nil
        categories << item.category.id
      end
    end

    if categories.length != categories.uniq.length
      errors[:items] << 'Wpis nie moze miec kilku sum z tej samej kategorii'
    end
  end

  def cannot_have_item_from_category_not_from_journals_year
    if journal.nil?
      errors[:journal] << "Wpis musi byc przypisany do ksiazki"
      return
    end

    items.each do |item|
      if item.nil? || item.category.nil? || item.category.year.nil?
        errors[:base] << "Wpis musi miec kategorie"
        return
      end

      if item.category.year != journal.year
        errors[:base] << "Wpis nie moze miec sumy dla kategorii z innego roku niz ksiazka: journal.year=#{journal.year} != category.year=#{item.category.year}"
        return
      end
    end
  end

  def reject_empty_items(attributed)
    return attributed['amount'] == nil || attributed['amount'].to_i == 0
  end

  def income_sum
    result = 0
    items.each do |item|
      if item.category.is_expense == false && item.amount != nil
        result += item.amount
      end
    end

    return result
  end

  def expense_sum
    result = 0
    items.each do |item|
      if item.category.is_expense == true && item.amount != nil
        result += item.amount
      end
    end

    return result
  end
end
