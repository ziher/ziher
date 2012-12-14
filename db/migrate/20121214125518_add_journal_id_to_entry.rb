class AddJournalIdToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :journal_id, :integer
  end
end
