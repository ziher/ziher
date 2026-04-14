require 'test_helper'

class KsefSettingTest < ActiveSupport::TestCase
  test "instance returns the singleton row, creating it if missing" do
    KsefSetting.delete_all
    setting = KsefSetting.instance
    assert_equal 1, setting.id
    assert_equal "https://api.ksef.mf.gov.pl", setting.api_url
    assert_equal setting.id, KsefSetting.instance.id
  end

  test "configured? is false when nip or cert is missing" do
    setting = KsefSetting.instance
    setting.update!(nip: nil, cert_pem: nil, key_pem: nil)
    assert_not setting.configured?

    setting.update!(nip: "1234567890", cert_pem: "x", key_pem: "y")
    assert setting.configured?
  end

  test "validates nip is exactly 10 digits when present" do
    setting = KsefSetting.instance
    setting.nip = "abc"
    assert_not setting.valid?
    setting.nip = "1234567890"
    assert setting.valid?
  end

  test "cert_pem and key_pem are encrypted at rest" do
    setting = KsefSetting.instance
    setting.update!(cert_pem: "PEM_CONTENT", key_pem: "KEY_CONTENT")
    raw = ActiveRecord::Base.connection.execute("SELECT cert_pem, key_pem FROM ksef_settings WHERE id=1").first
    assert_not_equal "PEM_CONTENT", raw["cert_pem"]
    assert_not_equal "KEY_CONTENT", raw["key_pem"]
  end
end
