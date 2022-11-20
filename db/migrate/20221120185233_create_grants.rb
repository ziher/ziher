class CreateGrants < ActiveRecord::Migration[5.2]
  def change
    create_table :grants do |t|
      t.string :name, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end
