class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.decimal :amount,              :precision => 9, :scale => 2
      t.decimal :amount_one_percent,  :precision => 9, :scale => 2
      t.references :entry
      t.references :category

      t.timestamps
    end
  end
end
