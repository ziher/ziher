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

  test "encrypt_aes_key_with_rsa wraps AES key with RSA-OAEP SHA-256" do
    session = Ksef::Crypto.generate_session_key
    encrypted = Ksef::Crypto.encrypt_aes_key_with_rsa(@public_pem, session.key)

    rsa = OpenSSL::PKey::RSA.new(@private_pem)
    decrypted = rsa.decrypt(encrypted, { rsa_padding_mode: "oaep", rsa_oaep_md: "SHA256", rsa_mgf1_md: "SHA256" })

    assert_equal session.key, decrypted
  end
end
