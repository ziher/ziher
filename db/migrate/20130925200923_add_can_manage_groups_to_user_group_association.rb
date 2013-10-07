class AddCanManageGroupsToUserGroupAssociation < ActiveRecord::Migration
  def change
    add_column :user_group_associations, :can_manage_groups, :boolean, :default => false
  end
end
