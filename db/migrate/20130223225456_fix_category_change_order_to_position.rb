class FixCategoryChangeOrderToPosition < ActiveRecord::Migration[5.2]
  def change
    rename_column :categories, :order, :position
  end
end
