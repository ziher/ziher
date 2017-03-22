class InventoryEntry < ActiveRecord::Base
  audited

  belongs_to :unit
  belongs_to :inventory_source

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

end
