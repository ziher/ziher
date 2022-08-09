class AddOrderToCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :order, :integer
  end
end
