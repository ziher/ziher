class AddIsActiveToUnits < ActiveRecord::Migration
  def change
    add_column :units, :is_active, :boolean, null: false, default: true
  end
end
