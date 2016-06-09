class InventorySource < ActiveRecord::Base
  has_many :inventory_entries

  validates :name, :presence => true, :uniqueness => true
end
