class InventorySource < ActiveRecord::Base
  attr_accessible :is_active, :name
  has_many :inventory_entries

  validates :name, :presence => true, :uniqueness => true
end
