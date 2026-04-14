module Ksef
  module Crypto
    SessionKey = Struct.new(:key, :iv, keyword_init: true)

    def self.generate_session_key
      SessionKey.new(
        key: OpenSSL::Random.random_bytes(32),
        iv:  OpenSSL::Random.random_bytes(16)
      )
    end

    def self.encrypt_key(raw_key, public_key_pem)
      rsa = OpenSSL::PKey::RSA.new(public_key_pem)
      encrypted = rsa.encrypt(raw_key, { rsa_padding_mode: "oaep", rsa_oaep_md: "SHA256", rsa_mgf1_md: "SHA256" })
      Base64.strict_encode64(encrypted)
    end
  end
end
