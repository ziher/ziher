class AddRunSinceAtToKsefSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :ksef_settings, :running_since_at, :datetime
  end
end
