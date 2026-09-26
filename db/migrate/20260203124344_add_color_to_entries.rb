class AddColorToEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :entries, :color, :string
  end
end
