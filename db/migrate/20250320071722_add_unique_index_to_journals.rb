class AddUniqueIndexToJournals < ActiveRecord::Migration[5.2]
  def change
    add_index :journals, [:unit_id, :year, :journal_type_id], unique: true, name: 'index_journals_on_unit_year_type'
  end
end
