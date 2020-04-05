class UserGroupAssociation < ApplicationRecord
  audited

  belongs_to :user
  belongs_to :group
end
