class AddCommentToInventoryEntries < ActiveRecord::Migration
  def change
    add_column :inventory_entries, :comment, :string
  end
end
