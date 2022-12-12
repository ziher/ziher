class ItemGrant < ApplicationRecord
    # audited

    belongs_to :item , required: true
    belongs_to :grant, required: true

    # validate there is only one grant type per item
    validates_uniqueness_of :item_id, scope: [:grant_id]

    validates :amount, numericality: { other_than: 0, message: "Wartość dla dotacji nie może wynosić zero" }
end
