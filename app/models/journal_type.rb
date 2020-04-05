class JournalType < ApplicationRecord
  audited

  FINANCE_TYPE_ID = 1
  BANK_TYPE_ID = 2

  def to_s
    return self.name
  end

end
