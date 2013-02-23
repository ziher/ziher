class AddIsOpenToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :is_open, :boolean
  end
end
