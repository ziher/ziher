class AddIsOnePercentToCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :is_one_percent, :boolean, :default => false
  end
end
