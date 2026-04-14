require "zip"
require "base64"
require "stringio"

module Ksef
  class Exporter
    InvoiceFile = Struct.new(:ksef_number, :xml, keyword_init: true)
    Result = Struct.new(:invoices, :hwm_date, :truncated, :last_permanent_storage_date, keyword_init: true)

    POLL_INTERVAL = 10
    POLL_TIMEOUT  = 5 * 60

    def initialize(setting, access_token:)
      @setting = setting
      @access_token = access_token
      @client = Ksef::Client.new(base_url: setting.api_url)
    end

    def run(date_from:, date_to: nil)
      session = Ksef::Crypto.generate_session_key
      der_base64 = Ksef::Certificates.fetch(@client, :symmetric_key_encryption)
      public_key_pem = Ksef::Crypto.public_key_pem_from_der_cert(der_base64)
      encrypted_key = Ksef::Crypto.encrypt_aes_key_with_rsa(public_key_pem, session.key)

      reference = request_export(
        date_from: date_from,
        date_to: date_to,
        encrypted_key: Base64.strict_encode64(encrypted_key),
        iv: Base64.strict_encode64(session.iv)
      )
      status_payload = poll(reference)
      pkg = status_payload["package"] || {}
      parts = Array(pkg["parts"])

      files = []
      parts.each do |part|
        encrypted_zip = @client.get_binary(part.fetch("url"))
        zip_bytes = Ksef::Crypto.decrypt_aes_cbc(encrypted_zip, session.key, session.iv)
        files.concat(unzip(zip_bytes))
      end

      Result.new(
        invoices: files,
        hwm_date: pkg["permanentStorageHwmDate"],
        truncated: pkg["isTruncated"] == true,
        last_permanent_storage_date: pkg["lastPermanentStorageDate"]
      )
    end

    private

    def request_export(date_from:, date_to:, encrypted_key:, iv:)
      date_range = {
        dateType: "PermanentStorage",
        from: date_from,
        restrictToPermanentStorageHwmDate: date_to.nil?
      }
      date_range[:to] = date_to if date_to

      body = {
        encryption: {
          encryptedSymmetricKey: encrypted_key,
          initializationVector: iv
        },
        filters: {
          subjectType: "Subject2",
          dateRange: date_range
        }
      }

      response = @client.post("/invoices/exports", body, access_token: @access_token)
      response.fetch("referenceNumber")
    end

    def poll(reference)
      deadline = Time.now + POLL_TIMEOUT
      loop do
        payload = @client.get("/invoices/exports/#{reference}", access_token: @access_token)
        code = payload.dig("status", "code").to_i
        return payload if code == 200 || code == 210
        if code >= 400
          raise Ksef::Client::Error.new(
            "KSeF export failed: #{code} #{payload.dig('status', 'description')}"
          )
        end
        raise Ksef::Client::Error.new("KSeF export polling timeout") if Time.now > deadline
        sleep POLL_INTERVAL
      end
    end

    MAX_ZIP_SIZE    = 100.megabytes
    MAX_ZIP_ENTRIES = 1_000

    def unzip(bytes)
      if bytes.bytesize > MAX_ZIP_SIZE
        raise Ksef::Client::Error, "ZIP package too large (#{bytes.bytesize} bytes, limit #{MAX_ZIP_SIZE})"
      end

      files = []
      Zip::File.open_buffer(StringIO.new(bytes)) do |zip|
        if zip.entries.size > MAX_ZIP_ENTRIES
          raise Ksef::Client::Error, "ZIP package has too many entries (#{zip.entries.size}, limit #{MAX_ZIP_ENTRIES})"
        end

        zip.each do |entry|
          next if entry.directory?
          next unless entry.name.end_with?(".xml")
          next if entry.name.end_with?("_metadata.json")
          ksef_number = File.basename(entry.name).sub(/\.xml\z/, "")
          files << InvoiceFile.new(ksef_number: ksef_number, xml: entry.get_input_stream.read)
        end
      end
      files
    end
  end
end
