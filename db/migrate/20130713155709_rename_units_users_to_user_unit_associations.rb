class RenameUnitsUsersToUserUnitAssociations < ActiveRecord::Migration[5.2]
  def change
    rename_table :units_users, :user_unit_associations
  end
end
