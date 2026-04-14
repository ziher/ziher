require 'test_helper'

class Ksef::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "superadmin can update setting" do
    sign_in users(:admin)
    patch ksef_setting_url, params: {
      ksef_setting: {
        nip: "1234567890",
        api_url: "https://api.ksef.mf.gov.pl",
        cert_pem: "PEM",
        key_pem:  "KEY"
      }
    }
    assert_redirected_to edit_ksef_setting_url
    setting = KsefSetting.instance
    assert_equal "1234567890", setting.nip
    assert_equal "PEM", setting.cert_pem
  end

  test "superadmin can view edit form" do
    sign_in users(:admin)
    get edit_ksef_setting_url
    assert_response :success
  end

  test "non-superadmin is redirected unauthorized" do
    sign_in users(:master_1zgm)
    get edit_ksef_setting_url
    assert_unauthorized
  end
end
