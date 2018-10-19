# encoding: utf-8
# TODO: wywalic stringi do I18n
class Entry < ActiveRecord::Base
  include ActiveModel::Validations
  audited

  has_many :items, dependent: :destroy
  belongs_to :journal
  has_one :linked_entry, :class_name => "Entry", :foreign_key => "linked_entry_id"

  accepts_nested_attributes_for :items
  accepts_nested_attributes_for :linked_entry

  validates :items, :presence => true
  validates :journal, :presence => true
  validates :date, :presence => true
  validates :name, :presence => true
  validates :document_number, :presence => true

  validate :must_be_from_journals_year

  validate :cannot_have_multiple_items_in_one_category
  validate :cannot_have_item_from_category_not_from_journals_year
  validate :must_be_either_expense_or_income
  validate :linked_entry_sum_must_match
  validate :linked_entry_must_be_opposite

  # if the journal is closed then everything inside should be frozen
  validate :should_not_change_if_journal_is_closed
  before_destroy :should_not_change_if_journal_is_closed

  after_save :recalculate_initial_balance
  after_destroy :recalculate_initial_balance

  def get_amount_for_category(category)
    result = self.items.find_all { |item| item.category == category }

    if result != nil && result.first != nil && result.first.amount != nil
      return result.first.amount
    else
      return 0
    end
  end

  def get_amount_one_percent_for_category(category)
    result = self.items.find_all { |item| item.category == category }

    if result != nil && result.first != nil && result.first.amount_one_percent != nil
      return result.first.amount_one_percent
    else
      return 0
    end
  end

  def has_category(category)
    existing_item = self.items.find { |item| item.category == category }
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

  def one_percent_category_item_should_have_same_amount_values
    result = true
    items.each do |item|
      if item.category.is_one_percent
        if item.amount != item.amount_one_percent
          errors[:items] << "Niepoprawny wpis dla kategorii 1% (amount=#{item.amount} != amount_one_percent=#{item.amount_one_percent})"
          result = false
        end
      end
    end
    return result
  end

  def must_be_from_journals_year
    if journal && self.date
      if self.date.year!= journal.year
        errors[:base] << "Wpis nie moze byc z innego roku: journal.year=#{journal.year} != entry.year=#{self.date.year}"
        return false
      end
    end
  end

  def cannot_have_item_from_category_not_from_journals_year
    if journal
      items.each do |item|
        if item.nil? || item.category.nil? || item.category.year.nil?
          errors[:base] << "Wpis musi miec kategorie z danego roku"
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
      unless journal.is_not_blocked(self.date)
        errors[:journal] << "Aby zmieniać wpisy książka musi być otwarta"
        return false
      end
    end
  end

  def must_be_either_expense_or_income
    is_expense = false
    is_income = false
    items.each do |item|
      if item.amount && item.amount > 0
        is_expense = true if item.category.is_expense
        is_income = true unless item.category.is_expense
        if is_expense && is_income
          errors[:base] << "Wpis nie może być jednocześnie wpływem i wydatkiem"
        end
      end
    end
  end

  def linked_entry_sum_must_match
    if linked_entry != nil
      if self.sum != linked_entry.sum
        errors[:linked_entry] << "Połączony wpis musi mieć taką samą kwotę"
      end
    end
  end

  def linked_entry_must_be_opposite
    if linked_entry != nil
      if self.is_expense == linked_entry.is_expense
        errors[:linked_entry] << "Połączony wpis musi być odwrotnego typu"
      end
    end
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

  def sum_one_percent
    result = 0
    items.each do |item|
      if !self.is_expense && item.category.is_one_percent && item.amount_one_percent
        result += item.amount_one_percent
      elsif item.amount_one_percent
        result += item.amount_one_percent
      end
    end

    return result
  end

  # recalculates initial balance for next year's journal
  def recalculate_initial_balance
    next_journal = self.journal.find_next_year_journal
    if next_journal
      next_journal.set_initial_balance
      next_journal.save!
    end
  end

  def verify_entry
    one_percent_category_item_should_have_same_amount_values
  end

  def link_to_edit
    "<a href='#{ENV['RAILS_RELATIVE_URL_ROOT']}/entries/#{self.to_param}/edit'>#{self.date.to_s} - #{self.journal.unit.name}</a>"
  end

end
