class AddIsOnePercentToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :is_one_percent, :boolean, :default => false
  end
end
