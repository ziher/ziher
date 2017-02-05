class UpdateDeviseInvitable < ActiveRecord::Migration
  def up
    change_column :users, :invitation_token, :string, :limit => nil

    add_column :users, :invitation_created_at, :datetime
  end

  def down
    change_column :users, :invitation_token, :string, :limit => 60
    remove_column :users, :invitation_created_at
  end
end
