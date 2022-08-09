class AddIsSuperadminToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_superadmin, :boolean, :default => false
  end
end

