class AddGroupsUnitsTable < ActiveRecord::Migration[5.2]
  def change 
    create_table :groups_units do |t|
      t.integer :group_id
      t.integer :unit_id

      t.timestamps
    end
  end
end
