class AddIdToUserUnitAssociation < ActiveRecord::Migration
  def change
    add_column :user_unit_associations, :id, :primary_key
  end
end
