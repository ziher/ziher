class CreateInventoryJournals < ActiveRecord::Migration
  def change
    create_table :inventory_journals do |t|
      t.integer :year
      t.references :unit
      t.boolean :open

      t.timestamps
    end
    add_index :inventory_journals, :unit_id
  end
end
