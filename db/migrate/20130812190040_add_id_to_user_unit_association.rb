class AddIdToUserUnitAssociation < ActiveRecord::Migration[5.2]
  def change
    add_column :user_unit_associations, :id, :primary_key
  end
end
