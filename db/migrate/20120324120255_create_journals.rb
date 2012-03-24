class CreateJournals < ActiveRecord::Migration
  def change
    create_table :journals do |t|
      t.integer :year
	  t.references :unit
      t.references :journal_type

      t.timestamps
    end
  end
end
