class UserUnitAssociation < ApplicationRecord
  audited

  belongs_to :user
  belongs_to :unit
end
