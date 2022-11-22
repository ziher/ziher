class AddGrantIdToCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :grant_id, :integer
    add_index  :categories, :grant_id
  end
end
