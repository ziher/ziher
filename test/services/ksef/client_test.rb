require 'test_helper'
require 'webmock/minitest'

class Ksef::ClientTest < ActiveSupport::TestCase
  def setup
    WebMock.disable_net_connect!
    @client = Ksef::Client.new(base_url: "https://example.test")
  end

  def teardown
    WebMock.reset!
  end

  test "GET returns parsed JSON body on 200" do
    stub_request(:get, "https://example.test/foo").to_return(
      status: 200, body: '{"hello":"world"}', headers: { "Content-Type" => "application/json" }
    )

    response = @client.get("/foo")
    assert_equal "world", response.fetch("hello")
  end

  test "POST sends JSON body and Authorization header" do
    stub_request(:post, "https://example.test/sessions")
      .with(
        body: '{"a":1}',
        headers: { "Authorization" => "TOKEN", "Content-Type" => "application/json" }
      )
      .to_return(status: 201, body: '{"ok":true}')

    response = @client.post("/sessions", { a: 1 }, headers: { "Authorization" => "TOKEN" })
    assert response["ok"]
  end

  test "raises Ksef::Client::Error on 4xx with body" do
    stub_request(:get, "https://example.test/missing").to_return(status: 404, body: '{"error":"not found"}')

    assert_raises(Ksef::Client::Error) { @client.get("/missing") }
  end

  test "honours Retry-After on 429 then succeeds" do
    stub_request(:get, "https://example.test/rate")
      .to_return({ status: 429, headers: { "Retry-After" => "0" } }, { status: 200, body: '{"k":"v"}' })

    response = @client.get("/rate")
    assert_equal "v", response["k"]
  end
end
