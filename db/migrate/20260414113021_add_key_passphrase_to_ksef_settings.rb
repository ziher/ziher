class AddKeyPassphraseToKsefSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :ksef_settings, :key_passphrase, :text
  end
end
