class RenameUnitsUsersToUserUnitAssociations < ActiveRecord::Migration
  def change
    rename_table :units_users, :user_unit_associations
  end
end
