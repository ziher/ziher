class AddIsDefaultToJournalType < ActiveRecord::Migration[5.2]
  def change
    add_column :journal_types, :is_default, :boolean, :default => false
  end
end
