class JournalGrant < ApplicationRecord
    belongs_to :journal
    belongs_to :grant

    # validate there is only one grant type per item
    validates_uniqueness_of :journal_id, scope: [:grant_id]

    validates :initial_grant_balance, numericality: true, null: false
end
