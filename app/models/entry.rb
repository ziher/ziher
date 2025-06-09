# encoding: utf-8
# TODO: wywalic stringi do I18n
class Entry < ApplicationRecord
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
    category_id = category.is_a?(Category) ? category.id : category
    amount = self.items.find { |item| item.category_id == category_id }&.amount
    amount || 0.0
  end

  def get_amount_one_percent_for_category(category)
    category_id = category.is_a?(Category) ? category.id : category
    amount_one_percent = self.items.find { |item| item.category_id == category_id }&.amount_one_percent
    amount_one_percent || 0.0
  end

  def get_grants_for_category(category)
    items.map(&:grants).flatten.uniq
  end

  def get_amount_for_category_and_grant(category, grant)
    category_id = category.is_a?(Category) ? category.id : category
    grant_id = grant.is_a?(Grant) ? grant.id : grant
    items.map{ |i| i.item_grants }.flatten.select{ |ig| ig.grant_id == grant_id && ig.item.category_id == category_id }.sum(&:amount)
  end

  def get_sum_for_grant(grant)
    grant_id = grant.is_a?(Grant) ? grant.id : grant
    items.map{ |i| i.item_grants }.flatten.select{ |ig| ig.grant_id == grant_id }.sum(&:amount)
  end

  def has_category(category)
    category_id = category.is_a?(Category) ? category.id : category
    items.find { |item| item.category_id == category_id }.present?
  end

  def cannot_have_multiple_items_in_one_category
    categories = []
    items.each do |item|
      if item.category != nil
        categories << item.category.id
      end
    end

    if categories.length != categories.uniq.length
      errors.add(:items, 'Wpis nie moze miec kilku sum z tej samej kategorii')
    end
  end

  def one_percent_category_item_should_have_same_amount_values
    items.each do |item|
      if item.category.is_one_percent
        if item.amount != item.amount_one_percent
          errors.add(:items, "Niepoprawny wpis dla kategorii 1,5% (amount=#{item.amount} != amount_one_percent=#{item.amount_one_percent})")
          throw :abort
        end
      end
    end
  end

  def must_be_from_journals_year
    if journal && self.date
      if self.date.year!= journal.year
        errors.add(:base, "Wpis nie moze byc z innego roku: journal.year=#{journal.year} != entry.year=#{self.date.year}")
        throw :abort
      end
    end
  end

  def cannot_have_item_from_category_not_from_journals_year
    if journal
      items.each do |item|
        if item.nil? || item.category.nil? || item.category.year.nil?
          errors.add(:base, "Wpis musi miec kategorie z danego roku")
          throw :abort
        end

        if item.category.year != journal.year
          errors.add(:base, "Wpis nie moze miec sumy dla kategorii z innego roku niz ksiazka: journal.year=#{journal.year} != category.year=#{item.category.year}")
          throw :abort
        end
      end
    end
  end

  def should_not_change_if_journal_is_closed
    if journal
      unless journal.is_not_blocked(self.date)
        errors.add(:journal, "Aby zmieniać wpisy książka musi być otwarta")
        throw :abort
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
          errors.add(:base, "Wpis nie może być jednocześnie wpływem i wydatkiem")
        end
      end
    end
  end

  def linked_entry_sum_must_match
    if linked_entry != nil
      if self.sum != linked_entry.sum
        errors.add(:linked_entry, "Połączony wpis musi mieć taką samą kwotę")
      end
    end
  end

  def linked_entry_must_be_opposite
    if linked_entry != nil
      if self.is_expense == linked_entry.is_expense
        errors.add(:linked_entry, "Połączony wpis musi być odwrotnego typu")
      end
    end
  end

  def sum
    @sum ||= items.sum { |item| item.amount ? item.amount : 0 }
  end

  def sum_one_percent
    return 0 if is_expense

    @sum_one_percent ||= items.select { |item| item.category.is_one_percent }.sum { |item| item.amount_one_percent ? item.amount_one_percent : 0 }
  end

  # recalculates initial balance for next year's journal
  def recalculate_initial_balance
    self.journal.recalculate_next_initial_balances
  end

  def verify_entry
    one_percent_category_item_should_have_same_amount_values
  end

  def link_to_edit
    "<a href='#{ENV['RAILS_RELATIVE_URL_ROOT']}/entries/#{self.to_param}/edit'>#{self.date.to_s} - #{self.journal.unit.name}</a>"
  end

  def balance
    return @balance if @balance

    initial_balance = journal.initial_balance
    entries = journal.entries.select { |e| e.date < date || (e.date == date && e.id <= id) }.sort_by(&:date)
    expense_sum = entries.select(&:is_expense).sum { |e| e.sum.to_d }
    income_sum = entries.select { |e| !e.is_expense }.sum { |e| e.sum.to_d }

    @balance = initial_balance + income_sum - expense_sum
  end
end
