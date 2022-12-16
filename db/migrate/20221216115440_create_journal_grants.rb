class CreateJournalGrants < ActiveRecord::Migration[5.2]
  def change
    create_table :journal_grants do |t|
      t.integer :journal_id, null: false
      t.integer :grant_id, null: false

      t.decimal :initial_grant_balance, default: 0.0, null: false, precision: 9, scale: 2

      t.timestamps
    end
  end
end
