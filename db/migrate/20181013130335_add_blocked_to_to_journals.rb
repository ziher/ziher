class AddBlockedToToJournals < ActiveRecord::Migration

  class Journal < ApplicationRecord
  end

  def change
    add_column :journals, :blocked_to, :date, null: true
  end
end
