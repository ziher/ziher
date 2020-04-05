# encoding: utf-8
# TODO: wywalic stringi do I18n
class Item < ApplicationRecord
  audited

  belongs_to :entry
  belongs_to :category

  before_save :set_same_values_for_one_percent_category

  validate :cannot_have_amount_one_percent_greater_than_amount
  validate :cannot_have_amount_one_percent_if_amount_is_nil

  def amount=(val)
    write_attribute :amount, val.to_s.gsub(/[,\s+]/, ',' => '.', '\s+' => '')
  end

  def amount_one_percent=(val)
    write_attribute :amount_one_percent, val.to_s.gsub(/[,\s+]/, ',' => '.', '\s+' => '')
  end

  def set_same_values_for_one_percent_category
    if self.category.is_one_percent then
      self.amount_one_percent = self.amount
    end
  end

  def cannot_have_amount_one_percent_greater_than_amount
    if self.amount != nil && self.amount_one_percent != nil
      if self.amount_one_percent > self.amount && !category.is_one_percent
        errors[:items] << " - wartość dla 1% (#{self.amount_one_percent}) musi być mniejsza niż wartość główna (#{self.amount})"
      end
    end
  end

  def cannot_have_amount_one_percent_if_amount_is_nil
    if self.amount == nil && self.amount_one_percent != nil && self.amount_one_percent != 0 then
      errors[:items] << " - podano wartość dla 1% (#{self.amount_one_percent}) bez podania wartości głównej"
    end
  end
  
end