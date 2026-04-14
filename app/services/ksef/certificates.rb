module Ksef
  module Certificates
    TTL = 24.hours

    USAGES = {
      ksef_token_encryption:    "KsefTokenEncryption",
      symmetric_key_encryption: "SymmetricKeyEncryption"
    }.freeze

    def self.fetch(client, usage)
      usage_str = USAGES.fetch(usage) { usage.to_s }
      Rails.cache.fetch(cache_key(client, usage_str), expires_in: TTL) do
        certs = client.get("/security/public-key-certificates")
        list  = certs.is_a?(Array) ? certs : Array(certs["publicKeyCertificates"] || certs["certificates"])
        match = list.find { |c| Array(c["usage"]).include?(usage_str) }
        raise Ksef::Client::Error.new("no KSeF certificate with usage=#{usage_str}") unless match
        match.fetch("certificate")
      end
    end

    def self.cache_key(client, usage_str)
      "ksef:cert:#{client.instance_variable_get(:@base_url)}:#{usage_str}"
    end
  end
end
