class InventorySource < ActiveRecord::Base
  audited

  has_many :inventory_entries

  validates :name, :presence => true, :uniqueness => true
end
