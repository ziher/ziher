class AddCodeToUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :units, :code, :string
    add_index :units, :code, :unique => true
  end
end
