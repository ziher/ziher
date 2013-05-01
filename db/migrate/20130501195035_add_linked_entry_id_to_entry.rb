class AddLinkedEntryIdToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :linked_entry_id, :integer
  end
end
