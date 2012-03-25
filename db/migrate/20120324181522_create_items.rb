class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.decimal :amount
      t.decimal :amount_one_percent
      t.references :entry
      t.references :category

      t.timestamps
    end
  end
end
