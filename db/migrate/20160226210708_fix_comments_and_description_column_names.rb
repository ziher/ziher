class FixCommentsAndDescriptionColumnNames < ActiveRecord::Migration[5.2]
  def change
    rename_column :inventory_entries, :description, :remark
    remove_column :inventory_entries, :comment
  end
end
