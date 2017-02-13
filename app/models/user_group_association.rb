class UserGroupAssociation < ActiveRecord::Base
  audited

  belongs_to :user
  belongs_to :group
end
