class CreateCashEntries < ActiveRecord::Migration
  def change
    create_table :cash_entries do |t|
      t.date :date
      t.string :name
      t.string :document_number
      t.decimal :amount
	  t.references :category
	  t.references :journal

      t.timestamps
    end
  end
end
