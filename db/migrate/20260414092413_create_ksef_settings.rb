class CreateKsefSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :ksef_settings do |t|
      t.string :nip, limit: 10
      t.string :api_url, default: "https://api.ksef.mf.gov.pl", null: false
      t.text :cert_pem # encrypted
      t.text :key_pem  # encrypted
      t.string :last_hwm_date
      t.string :last_permanent_storage_date
      t.datetime :last_sync_at
      t.string :last_sync_status
      t.text :last_sync_error
      t.timestamps
    end
  end
end
