class CreateInventorySources < ActiveRecord::Migration
  def change
    create_table :inventory_sources do |t|
      t.string :name
      t.boolean :is_active

      t.timestamps
    end
  end
end
