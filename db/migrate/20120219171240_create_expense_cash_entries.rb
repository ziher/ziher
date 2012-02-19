class CreateExpenseCashEntries < ActiveRecord::Migration
  def change
    create_table :expense_cash_entries do |t|
      t.date :date
      t.string :name
      t.string :document_number
      t.string :comment
      t.decimal :razem
      t.decimal :razem_jeden_procent
      t.decimal :wyposazenie
      t.decimal :wyposazenie_jeden_procent
      t.decimal :materialy
      t.decimal :materialy_jeden_procent
      t.decimal :wyzywienie
      t.decimal :wyzywienie_jeden_procent
      t.decimal :uslugi
      t.decimal :uslugi_jeden_procent
      t.decimal :transport
      t.decimal :transport_jeden_procent
      t.decimal :czynsz
      t.decimal :czynsz_jeden_procent
      t.decimal :ubezpieczenie
      t.decimal :ubezpieczenie_jeden_procent
      t.decimal :inne
      t.decimal :inne_jeden_procent
      t.decimal :wynagrodzenie
      t.decimal :wynagrodzenie_jeden_procent
      t.decimal :skladki
      t.decimal :skladki_jeden_procent

      t.timestamps
    end
  end
end
