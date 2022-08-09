class CreateEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :entries do |t|
      t.date :date
      t.string :name
      t.string :document_number

      t.timestamps
    end
  end
end
