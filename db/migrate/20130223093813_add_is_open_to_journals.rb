class AddIsOpenToJournals < ActiveRecord::Migration[5.2]
  def change
    add_column :journals, :is_open, :boolean
  end
end
