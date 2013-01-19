class AddIsDefaultToJournalType < ActiveRecord::Migration
  def change
    add_column :journal_types, :is_default, :boolean, :default => false
  end
end
