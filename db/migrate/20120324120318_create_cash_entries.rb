class CreateCashEntries < ActiveRecord::Migration
  def change
    create_table :cash_entries do |t|
      t.integer :id
      t.date :date
      t.string :name
      t.string :document_number
      t.decimal :amount

      t.timestamps
    end
  end
end
