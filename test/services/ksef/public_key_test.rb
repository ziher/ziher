require 'test_helper'
require 'webmock/minitest'

class Ksef::PublicKeyTest < ActiveSupport::TestCase
  def setup
    WebMock.disable_net_connect!
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  def teardown
    WebMock.reset!
    Rails.cache = @original_cache
  end

  test "fetches PEM and caches for subsequent calls" do
    stub = stub_request(:get, "https://api.example/auth/public-key")
      .to_return(status: 200, body: '{"publicKey":"-----BEGIN PUBLIC KEY-----\nABC\n-----END PUBLIC KEY-----"}',
                 headers: { "Content-Type" => "application/json" })

    client = Ksef::Client.new(base_url: "https://api.example")
    key1 = Ksef::PublicKey.fetch(client)
    key2 = Ksef::PublicKey.fetch(client)

    assert_match(/BEGIN PUBLIC KEY/, key1)
    assert_equal key1, key2
    assert_requested stub, times: 1
  end
end
