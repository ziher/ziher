class Grant < ApplicationRecord
  audited

  validates :name, presence: true
  validates :description, presence: true
end

