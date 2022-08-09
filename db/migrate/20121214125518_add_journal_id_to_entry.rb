class AddJournalIdToEntry < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :journal_id, :integer
  end
end
