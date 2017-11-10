class InventorySource < ActiveRecord::Base
  audited

  has_many :inventory_entries

  validates :name, :presence => true, :uniqueness => true

  # TODO: 1st inventory entry must be equal to JournalType::FINANCE_TYPE_ID (id and name)
  # TODO: 2nd inventory entry must be equal to JournalType::BANK_TYPE_ID (id and name)
end
