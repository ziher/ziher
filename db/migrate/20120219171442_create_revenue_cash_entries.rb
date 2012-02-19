class CreateRevenueCashEntries < ActiveRecord::Migration
  def change
    create_table :revenue_cash_entries do |t|
      t.date :date
      t.string :name
      t.string :document_number
      t.string :comment
      t.decimal :razem
      t.decimal :darowizny
      t.decimal :akcje_zarobkowe
      t.decimal :jeden_procent
      t.decimal :inne
      t.decimal :skladki

      t.timestamps
    end
  end
end
