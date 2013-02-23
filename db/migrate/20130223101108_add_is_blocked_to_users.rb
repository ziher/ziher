class AddIsBlockedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_blocked, :boolean, :default => false
  end
end
