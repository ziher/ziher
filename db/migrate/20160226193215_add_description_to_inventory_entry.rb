class AddDescriptionToInventoryEntry < ActiveRecord::Migration[5.2]
  def change
    add_column :inventory_entries, :description, :string
  end
end
