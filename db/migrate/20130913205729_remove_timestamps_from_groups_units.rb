class RemoveTimestampsFromGroupsUnits < ActiveRecord::Migration
  def change
    remove_column :groups_units, :created_at
    remove_column :groups_units, :updated_at
  end
end
