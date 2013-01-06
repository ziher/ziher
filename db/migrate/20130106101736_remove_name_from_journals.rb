class RemoveNameFromJournals < ActiveRecord::Migration
  def up
    remove_column :journals, :name
  end

  def down
    add_column :journals, :name, :string
  end
end
