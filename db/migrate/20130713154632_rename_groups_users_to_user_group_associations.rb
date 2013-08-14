class RenameGroupsUsersToUserGroupAssociations < ActiveRecord::Migration
  def change
    rename_table :groups_users, :user_group_associations
  end
end
