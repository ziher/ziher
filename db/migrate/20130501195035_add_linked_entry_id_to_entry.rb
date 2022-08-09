class AddLinkedEntryIdToEntry < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :linked_entry_id, :integer
  end
end
