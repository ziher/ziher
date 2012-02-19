class InventoryJournal < ActiveRecord::Base
  belongs_to :unit
  has_many :inventory_entries
end
