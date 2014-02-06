class CreateInventoryEntries < ActiveRecord::Migration
  def change
    create_table :inventory_entries do |t|
      t.date :date
      t.string :stock_number
      t.string :name
      t.string :document_number
      t.string :source
      t.integer :amount
      t.boolean :is_expense
      t.decimal :total_value, :precision => 9, :scale => 2
      t.string :comment
      t.integer :unit_id

      t.timestamps
    end
  end
end
