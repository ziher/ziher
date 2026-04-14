require "openssl"
require "base64"

module Ksef
  module Crypto
    SessionKey = Struct.new(:key, :iv, keyword_init: true)

    def self.generate_session_key
      SessionKey.new(
        key: OpenSSL::Random.random_bytes(32),
        iv:  OpenSSL::Random.random_bytes(16)
      )
    end

    def self.encrypt_aes_key_with_rsa(public_key_pem, aes_key_bytes)
      rsa = OpenSSL::PKey::RSA.new(public_key_pem)
      rsa.encrypt(aes_key_bytes, { rsa_padding_mode: "oaep", rsa_oaep_md: "SHA256", rsa_mgf1_md: "SHA256" })
    end

    def self.decrypt_aes_cbc(ciphertext_bytes, key_bytes, iv_bytes)
      cipher = OpenSSL::Cipher.new("AES-256-CBC")
      cipher.decrypt
      cipher.key = key_bytes
      cipher.iv = iv_bytes
      cipher.update(ciphertext_bytes) + cipher.final
    end

    def self.public_key_pem_from_der_cert(der_base64)
      der = Base64.decode64(der_base64)
      cert = OpenSSL::X509::Certificate.new(der)
      cert.public_key.to_pem
    end
  end
end
