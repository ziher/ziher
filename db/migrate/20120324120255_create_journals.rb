class CreateJournals < ActiveRecord::Migration[5.2]
  def change
    create_table :journals do |t|
      t.integer :year
	    t.references :unit
      t.references :journal_type

      t.timestamps
    end
  end
end
