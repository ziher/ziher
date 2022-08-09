class AddAuthorizationToGroupsAndUnits < ActiveRecord::Migration[5.2]
  def change
    add_column :units_users, :can_view_entries, :boolean, :default => false
    add_column :units_users, :can_manage_entries, :boolean, :default => false
    add_column :units_users, :can_close_journals, :boolean, :default => false
    add_column :units_users, :can_manage_users, :boolean, :default => false

    add_column :groups_users, :can_view_entries, :boolean, :default => false
    add_column :groups_users, :can_manage_entries, :boolean, :default => false
    add_column :groups_users, :can_close_journals, :boolean, :default => false
    add_column :groups_users, :can_manage_users, :boolean, :default => false
    add_column :groups_users, :can_manage_units, :boolean, :default => false
  end
end
