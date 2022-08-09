class CreateUnitsUsers < ActiveRecord::Migration[5.2]
  def up
    create_table :units_users, :id => false do |t|
      t.integer :unit_id
      t.integer :user_id
    end
  end

  def down
    drop_table :units_users
  end
end
