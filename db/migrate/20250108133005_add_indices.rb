class AddIndices < ActiveRecord::Migration[5.2]
  def change
    add_index :categories, :year
    add_index :categories, :is_expense
    add_index :entries, :journal_id
    add_index :inventory_entries, :unit_id
    add_index :inventory_entries, :inventory_source_id
    add_index :inventory_entries, :is_expense
    add_index :inventory_entries, :date
    add_index :item_grants, :item_id
    add_index :item_grants, :grant_id
    add_index :journal_grants, :journal_id
    add_index :journal_grants, :grant_id
    add_index :journals, :year
    add_index :journals, :journal_type_id
    add_index :units, :is_active
    add_index :user_group_associations, :user_id
    add_index :user_group_associations, :group_id
    add_index :user_unit_associations, :user_id
    add_index :user_unit_associations, :unit_id
  end
end
