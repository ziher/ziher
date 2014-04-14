class InventorySource < ActiveRecord::Base
  attr_accessible :is_active, :name

  validates :name, :presence => true, :uniqueness => true
end
