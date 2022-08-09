class CreateSubgroups < ActiveRecord::Migration[5.2]
  def change
    create_table :subgroups, :id => false do |t|
      t.integer :group_id
      t.integer :subgroup_id
    end
  end
end
