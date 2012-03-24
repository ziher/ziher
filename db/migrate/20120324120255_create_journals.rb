class CreateJournals < ActiveRecord::Migration
  def change
    create_table :journals do |t|
      t.integer :id
      t.integer :year
      t.string :type

      t.timestamps
    end
  end
end
