class CreateCashEntries < ActiveRecord::Migration
  def change
    create_table :cash_entries do |t|
      t.date :date
      t.string :name
      t.string :document_number
      t.string :comment

      t.timestamps
    end
  end
end
