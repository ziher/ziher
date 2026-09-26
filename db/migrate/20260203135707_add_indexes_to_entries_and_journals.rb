class AddIndexesToEntriesAndJournals < ActiveRecord::Migration[8.0]
  def change
    # Add composite index for faster entry lookups by journal and date
    add_index :entries, [:journal_id, :date, :id], name: 'index_entries_on_journal_date_id'
    
    # Add composite index for faster journal lookups
    add_index :journals, [:unit_id, :journal_type_id, :year], name: 'index_journals_on_unit_type_year'
    
    # Add index on entries date for balance calculations
    add_index :entries, :date unless index_exists?(:entries, :date)
  end
end
