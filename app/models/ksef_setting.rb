class KsefSetting < ApplicationRecord
  encrypts :cert_pem
  encrypts :key_pem
  encrypts :key_passphrase

  validates :nip, format: { with: /\A\d{10}\z/ }, allow_blank: true
  validates :api_url, presence: true

  ADVISORY_LOCK_ID = 4242420001 # arbitrary fixed int for pg_advisory_xact_lock

  def self.instance
    transaction do
      connection.execute("SELECT pg_advisory_xact_lock(#{ADVISORY_LOCK_ID})")
      first_or_create!(id: 1) do |s|
        s.api_url = "https://api.ksef.mf.gov.pl"
      end
    end
  end

  def configured?
    nip.present? && cert_pem.present? && key_pem.present?
  end
end
