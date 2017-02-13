# encoding: utf-8
# TODO: wywalic stringi do I18n
class Item < ActiveRecord::Base
  audited

  belongs_to :entry
  belongs_to :category

  before_save :set_same_values_for_one_percent_category

  validates :amount, :presence => true

  validate :cannot_have_amount_one_percent_greater_than_amount
  validate :cannot_have_amount_one_percent_if_amount_is_nil

  def set_same_values_for_one_percent_category
    if self.category.is_one_percent then
      self.amount_one_percent = self.amount
    end
  end

  def cannot_have_amount_one_percent_greater_than_amount
    if self.amount != nil && self.amount_one_percent != nil
      if self.amount_one_percent > self.amount && !category.is_one_percent
        errors[:items] << "Wartość 1% (#{self.amount_one_percent}) musi być mniejsza niż podana suma (#{self.amount})"
      end
    end
  end

  def cannot_have_amount_one_percent_if_amount_is_nil
    if self.amount == nil && self.amount_one_percent != nil && self.amount_one_percent != 0 then
      raise "Wydarzyło się coś bardzo nieoczekiwanego - zgłoś się do swojego administratora ZiHeRa."
    end
  end
  
end