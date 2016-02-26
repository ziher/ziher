class FixCommentsAndDescriptionColumnNames < ActiveRecord::Migration
  def change
    rename_column :inventory_entries, :description, :remark
    remove_column :inventory_entries, :comment
  end
end
