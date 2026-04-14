require 'test_helper'
require 'webmock/minitest'
require 'zip'

class Ksef::ExporterTest < ActiveSupport::TestCase
  def setup
    skip "KSeF v2 port: v1 export status shape (status: 'completed') and path layout retired; needs rewrite for /v2/invoices/exports with numeric status.code"
    WebMock.disable_net_connect!
    @client = Ksef::Client.new(base_url: "https://api.example")
    @setting = KsefSetting.instance
    @setting.update!(
      nip: "1234567890",
      api_url: "https://api.example",
      cert_pem: File.read(Rails.root.join("test/fixtures/files/ksef/public_key.pem")),
      key_pem:  File.read(Rails.root.join("test/fixtures/files/ksef/private_key.pem"))
    )
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  def teardown
    WebMock.reset!
    Rails.cache = @original_cache
  end

  test "happy path: requests, polls until completed, downloads and unzips parts" do
    sample_xml = File.read(Rails.root.join("test/fixtures/files/ksef/sample_fa3.xml"))
    public_pem = File.read(Rails.root.join("test/fixtures/files/ksef/public_key.pem"))

    stub_request(:get, "https://api.example/auth/public-key")
      .to_return(status: 200, body: { publicKey: public_pem }.to_json,
                 headers: { "Content-Type" => "application/json" })

    stub_request(:post, "https://api.example/invoices/exports")
      .to_return(status: 200, body: { referenceNumber: "REF1" }.to_json,
                 headers: { "Content-Type" => "application/json" })

    stub_request(:get, "https://api.example/invoices/exports/REF1/status")
      .to_return(status: 200, body: {
        status: "completed",
        permanentStorageHwmDate: "2026-04-14T10:00:00Z",
        isTruncated: false,
        parts: [{ partId: 1, downloadUrl: "https://api.example/invoices/exports/REF1/parts/1" }]
      }.to_json, headers: { "Content-Type" => "application/json" })

    zip_buffer = Zip::OutputStream.write_buffer do |zos|
      zos.put_next_entry("invoice.xml")
      zos.write(sample_xml)
    end
    zip_buffer.rewind

    stub_request(:get, "https://api.example/invoices/exports/REF1/parts/1")
      .to_return(status: 200, body: zip_buffer.read)

    result = Ksef::Exporter.new(@setting, access_token: "TOKEN").run(date_from: "2026-01-01T00:00:00Z")

    assert_equal "2026-04-14T10:00:00Z", result.hwm_date
    assert_equal 1, result.invoices.size
    assert_includes result.invoices.first, "<P_2>FV/2026/03/0123</P_2>"
  end
end
