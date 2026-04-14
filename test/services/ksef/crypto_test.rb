require 'test_helper'

class Ksef::CryptoTest < ActiveSupport::TestCase
  def setup
    @public_pem  = File.read(Rails.root.join("test/fixtures/files/ksef/public_key.pem"))
    @private_pem = File.read(Rails.root.join("test/fixtures/files/ksef/private_key.pem"))
  end

  test "generate_session_key returns 32-byte key and 16-byte iv" do
    session = Ksef::Crypto.generate_session_key
    assert_equal 32, session.key.bytesize
    assert_equal 16, session.iv.bytesize
  end

  test "encrypt_key wraps AES key with RSA-OAEP SHA-256" do
    session = Ksef::Crypto.generate_session_key
    encrypted_b64 = Ksef::Crypto.encrypt_key(session.key, @public_pem)

    encrypted = Base64.strict_decode64(encrypted_b64)
    rsa = OpenSSL::PKey::RSA.new(@private_pem)
    decrypted = rsa.decrypt(encrypted, { rsa_padding_mode: "oaep", rsa_oaep_md: "SHA256", rsa_mgf1_md: "SHA256" })

    assert_equal session.key, decrypted
  end
end
