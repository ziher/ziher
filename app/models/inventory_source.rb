class InventorySource < ActiveRecord::Base
  audited

  has_many :inventory_entries
  validate :prevent_changes_for_finance_bank
  before_destroy :prevent_changes_for_finance_bank
  before_destroy :check_for_inventory_entries

  validates :name, :presence => true, :uniqueness => true

  InventorySource::FINANCE_TYPE_NAME = "ks. finansowa"
  InventorySource::FINANCE_TYPE_ID = JournalType::FINANCE_TYPE_ID

  InventorySource::BANK_TYPE_NAME = "ks. bankowa"
  InventorySource::BANK_TYPE_ID = JournalType::BANK_TYPE_ID

  # TODO: 1st inventory entry must be equal to JournalType::FINANCE_TYPE_ID (id and name)
  # TODO: 2nd inventory entry must be equal to JournalType::BANK_TYPE_ID (id and name)

  private

  def prevent_changes_for_finance_bank
    if self.id == InventorySource::FINANCE_TYPE_ID || self.id == InventorySource::BANK_TYPE_ID
      errors[:inventory_source] << "Nie można edytować źródła #{self.name}"
      return false

      # TODO: Rails 5
      # throw(:abort)
    end
  end

  def check_for_inventory_entries
    return true if inventory_entries.count == 0

    errors[:inventory_source] << "Nie można kasować źródła dla którego istnieją wpisy"
    return false

    # TODO: Rails 5
    # throw(:abort)
  end

end