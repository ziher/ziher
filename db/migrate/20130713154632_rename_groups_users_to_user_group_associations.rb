class RenameGroupsUsersToUserGroupAssociations < ActiveRecord::Migration[5.2]
  def change
    rename_table :groups_users, :user_group_associations
  end
end
