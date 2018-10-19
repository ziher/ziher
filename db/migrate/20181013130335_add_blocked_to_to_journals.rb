class AddBlockedToToJournals < ActiveRecord::Migration

  class Journal < ActiveRecord::Base
  end

  def change
    add_column :journals, :blocked_to, :date, null: true
  end
end
