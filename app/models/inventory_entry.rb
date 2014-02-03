class InventoryEntry < ActiveRecord::Base
  belongs_to :unit

  validates :unit, :presence => true
  validates :date, :presence => true
  validates :stock_number, :presence => true
  validates :name, :presence => true
  validates :document_number, :presence => true
  validates :source, :presence => true
  validates :amount, :presence => true
  validates :total_value, :presence => true

end
