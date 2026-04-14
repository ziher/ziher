require "zip"

module Ksef
  class Exporter
    Result = Struct.new(:invoices, :hwm_date, :truncated, :last_permanent_storage_date, keyword_init: true)

    POLL_INTERVAL = 5
    POLL_TIMEOUT  = 5 * 60

    def initialize(setting, access_token:)
      @setting = setting
      @access_token = access_token
      @client = Ksef::Client.new(base_url: setting.api_url)
    end

    def run(date_from:)
      session = Ksef::Crypto.generate_session_key
      public_key = Ksef::PublicKey.fetch(@client)
      encrypted_key = Ksef::Crypto.encrypt_key(session.key, public_key)

      reference = request_export(date_from: date_from, encrypted_key: encrypted_key, iv: session.iv)
      status_payload = poll(reference)
      xmls = download_parts(status_payload.fetch("parts"))

      Result.new(
        invoices: xmls,
        hwm_date: status_payload["permanentStorageHwmDate"],
        truncated: status_payload["isTruncated"] == true,
        last_permanent_storage_date: status_payload["lastPermanentStorageDate"]
      )
    end

    private

    def request_export(date_from:, encrypted_key:, iv:)
      body = {
        encryption: {
          encryptedSymmetricKey: encrypted_key,
          initializationVector: Base64.strict_encode64(iv)
        },
        filters: {
          subjectType: "Subject2",
          dateRange: { dateType: "PermanentStorage", from: date_from }
        }
      }
      response = @client.post("/invoices/exports", body, headers: auth_headers)
      response.fetch("referenceNumber")
    end

    def poll(reference)
      deadline = Time.current + POLL_TIMEOUT
      loop do
        payload = @client.get("/invoices/exports/#{reference}/status", headers: auth_headers)
        return payload if payload["status"] == "completed"
        raise Ksef::Client::Error, "export failed: #{payload['error']}" if payload["status"] == "error"
        raise Ksef::Client::Error, "export polling timeout" if Time.current > deadline
        sleep POLL_INTERVAL
      end
    end

    def download_parts(parts)
      parts.flat_map do |part|
        zip_bytes = @client.get_raw(URI(part.fetch("downloadUrl")).request_uri, headers: auth_headers)
        unzip(zip_bytes)
      end
    end

    def unzip(bytes)
      xmls = []
      Zip::File.open_buffer(StringIO.new(bytes)) do |zip|
        zip.each do |entry|
          next unless entry.name.end_with?(".xml")
          xmls << entry.get_input_stream.read
        end
      end
      xmls
    end

    def auth_headers
      { "Authorization" => @access_token }
    end
  end
end
