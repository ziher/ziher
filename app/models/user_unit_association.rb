class UserUnitAssociation < ActiveRecord::Base
  audited

  belongs_to :user
  belongs_to :unit
end
