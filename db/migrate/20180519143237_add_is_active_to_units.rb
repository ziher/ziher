class AddIsActiveToUnits < ActiveRecord::Migration[5.2]
  def change
    add_column :units, :is_active, :boolean, null: false, default: true
  end
end
