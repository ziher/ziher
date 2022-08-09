class AddCanManageGroupsToUserGroupAssociation < ActiveRecord::Migration[5.2]
  def change
    add_column :user_group_associations, :can_manage_groups, :boolean, :default => false
  end
end
