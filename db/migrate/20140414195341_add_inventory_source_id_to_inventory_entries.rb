class AddInventorySourceIdToInventoryEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :inventory_entries, :inventory_source_id, :integer
    remove_column :inventory_entries, :source
  end
end
