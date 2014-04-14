class AddInventorySourceIdToInventoryEntries < ActiveRecord::Migration
  def change
    add_column :inventory_entries, :inventory_source_id, :integer
    remove_column :inventory_entries, :source
  end
end
