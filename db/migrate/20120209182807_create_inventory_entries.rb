class CreateInventoryEntries < ActiveRecord::Migration
  def change
    create_table :inventory_entries do |t|
      t.date :date
      t.string :name
      t.string :document_number
      t.integer :amount
      t.decimal :unit_price
      t.string :source
      t.string :stock_number

      t.timestamps
    end
  end
end
