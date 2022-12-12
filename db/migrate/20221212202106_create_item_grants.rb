class CreateItemGrants < ActiveRecord::Migration[5.2]
  def change
    create_table :item_grants do |t|
      t.integer :item_id, null: false
      t.integer :grant_id, null: false
      t.decimal :amount, default: 0.0, null: false, precision: 9, scale: 2

      t.timestamps
    end
  end
end
