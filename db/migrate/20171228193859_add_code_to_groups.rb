class AddCodeToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :code, :string
  end
end
