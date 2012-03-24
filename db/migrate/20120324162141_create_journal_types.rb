class CreateJournalTypes < ActiveRecord::Migration
  def change
    create_table :journal_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
