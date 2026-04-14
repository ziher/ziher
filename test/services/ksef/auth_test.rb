require 'test_helper'
require 'webmock/minitest'

class Ksef::AuthTest < ActiveSupport::TestCase
  def setup
    WebMock.disable_net_connect!
    @setting = KsefSetting.instance
    @setting.update!(
      nip: "1234567890",
      api_url: "https://api.example",
      cert_pem: File.read(Rails.root.join("test/fixtures/files/ksef/public_key.pem")),
      key_pem:  File.read(Rails.root.join("test/fixtures/files/ksef/private_key.pem"))
    )
  end

  def teardown
    WebMock.reset!
  end

  test "obtains an access token via challenge → sessions flow" do
    challenge_stub = stub_request(:post, "https://api.example/auth/challenge")
      .to_return(status: 200, body: '{"challenge":"CHAL","timestamp":"2026-04-14T10:00:00Z"}',
                 headers: { "Content-Type" => "application/json" })

    sessions_stub = stub_request(:post, "https://api.example/auth/sessions")
      .to_return(status: 200, body: '{"accessToken":{"token":"ACCESS_TOKEN"}}',
                 headers: { "Content-Type" => "application/json" })

    token = Ksef::Auth.access_token(@setting)
    assert_equal "ACCESS_TOKEN", token
    assert_requested challenge_stub
    assert_requested sessions_stub
  end
end
