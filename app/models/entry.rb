# encoding: utf-8
class Entry < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :items, dependent: :destroy
  belongs_to :journal

  accepts_nested_attributes_for :items, :reject_if => :reject_empty_items

  validates :items, :presence => {:message => "Wpis musi miec przynajmniej jedna sume"}
  validates :journal, :presence => {:message => "Wpis musi byc przypisany do ksiazki"}
  validate :cannot_have_multiple_items_in_one_category
  validate :cannot_have_item_from_category_not_from_journals_year
  validate :must_be_either_expense_or_income

  # if the journal is closed then everything inside should be frozen
  validate :should_not_change_if_journal_is_closed
  before_destroy :should_not_change_if_journal_is_closed

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
    if journal
      items.each do |item|
        if item.nil? || item.category.nil? || item.category.year.nil?
          errors[:base] << "Wpis musi miec kategorie"
          return false
        end

        if item.category.year != journal.year
          errors[:base] << "Wpis nie moze miec sumy dla kategorii z innego roku niz ksiazka: journal.year=#{journal.year} != category.year=#{item.category.year}"
          return false
        end
      end
    end
  end

  def should_not_change_if_journal_is_closed
    if journal
      if not journal.is_open?
        errors[:journal] << "Aby zmieniać wpisy książka musi być otwarta"
        return false
      end
    end
  end

  def must_be_either_expense_or_income
    is_expense = false
    is_income = false
    items.each do |item|
      if item.amount and item.amount > 0
        is_expense = true if item.category.is_expense
        is_income = true if not item.category.is_expense
        if is_expense and is_income
          errors[:base] << "Wpis nie może być jednocześnie wpływem i wydatkiem"
        end
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

  def sum
    result = 0
    items.each do |item|
      if item.amount
        result += item.amount
      end
    end

    return result
  end
end
