class AddDescriptionToInventoryEntry < ActiveRecord::Migration
  def change
    add_column :inventory_entries, :description, :string
  end
end
