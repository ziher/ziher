class InventoryEntry < ApplicationRecord
  audited

  belongs_to :unit
  belongs_to :inventory_source

  before_save :inventory_source_is_active
  before_save :finance_source_is_active
  before_destroy :finance_source_is_active

  validates :unit, :presence => true
  validates :date, :presence => true
  validates :stock_number, :presence => true
  validates :name, :presence => true
  validates :document_number, :presence => true
  validates :inventory_source, :presence => true
  validates :amount, :presence => true
  validates :total_value, :presence => true

  def total_value=(val)
    write_attribute :total_value, val.to_s.gsub(/[,\s+]/, ',' => '.', '\s+' => '')
  end

  def self.by_year(year)
    dt = DateTime.new(year)
    boy = dt.beginning_of_year
    eoy = dt.end_of_year
    where("date >= ? and date <= ?", boy, eoy)
  end

  def unit_price
    self.total_value / self.amount
  end

  def signed_total_value
    self.total_value * (self.is_expense ? -1 : 1)
  end

  private

  def inventory_source_is_active
    if inventory_source.is_active
      return true
    end

    errors.add(:inventory_entry, "Nie można użyć nieaktywnego źródła #{inventory_source.name}")
    return false
  end

  def finance_source_is_active
    if inventory_source.id != InventorySource::FINANCE_TYPE_ID && inventory_source.id != InventorySource::BANK_TYPE_ID
      return true
    end

    type = JournalType.find(inventory_source.id)
    journal = Journal.find_by_unit_and_year_and_type(unit, date.year, type)
    if (not journal.nil?) && journal.is_not_blocked(self.date)
      return true
    end

    errors.add(:inventory_entry, "Źródło #{inventory_source.name} dla roku #{date.year} jest zamknięte")
    return false
  end

end
