class CreateInventorySources < ActiveRecord::Migration[5.2]
  def change
    create_table :inventory_sources do |t|
      t.string :name
      t.boolean :is_active

      t.timestamps
    end

    add_index :inventory_sources, :name, :unique => true
  end
end
