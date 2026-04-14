require "openssl"
require "base64"
require "securerandom"
require "time"

module Ksef
  # XAdES-BASELINE-B (ENVELOPED) builder for KSeF API v2 /auth/xades-signature.
  #
  # Canonical XML forms are
  # assembled as strings (not via a DOM) so the byte layout matches the TS
  # implementation exactly — the KSeF verifier uses Inclusive C14N 1.0, and
  # matching byte-for-byte sidesteps canonicalization library differences.
  module Xades
    DS_NS                   = "http://www.w3.org/2000/09/xmldsig#".freeze
    XADES_NS                = "http://uri.etsi.org/01903/v1.3.2#".freeze
    XADES_SIGNED_PROPS_TYPE = "http://uri.etsi.org/01903#SignedProperties".freeze
    KSEF_AUTH_NS            = "http://ksef.mf.gov.pl/auth/token/2.0".freeze
    C14N                    = "http://www.w3.org/TR/2001/REC-xml-c14n-20010315".freeze
    ENVELOPED_SIG           = "http://www.w3.org/2000/09/xmldsig#enveloped-signature".freeze
    SHA256_DIGEST           = "http://www.w3.org/2001/04/xmlenc#sha256".freeze
    RSA_SHA256_SIG          = "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256".freeze
    ECDSA_SHA256_SIG        = "http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256".freeze
    ECDSA_SHA384_SIG        = "http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha384".freeze
    ECDSA_SHA512_SIG        = "http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha512".freeze

    def self.build_auth_document(challenge:, nip:, cert_pem:, private_key_pem:, passphrase: nil)
      sig_id = "Signature-#{SecureRandom.hex(4).upcase}"
      sig_props_id = "SignedProperties-#{sig_id}"

      cert_der_base64 = pem_to_der_base64(cert_pem)
      cert_der_bytes  = Base64.decode64(cert_der_base64)
      cert_digest     = sha256_b64(cert_der_bytes)

      cert = OpenSSL::X509::Certificate.new(cert_pem)
      issuer_dn = format_dn(cert.issuer)
      serial_number = cert.serial.to_s(10)

      signing_time = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")

      alg = key_info(private_key_pem, passphrase)

      auth_request_canonical = build_auth_request_canonical(challenge, nip)
      document_digest = sha256_b64(auth_request_canonical)

      signed_props_canonical = build_signed_props_canonical(
        sig_props_id, signing_time, cert_digest, issuer_dn, serial_number
      )
      signed_props_digest = sha256_b64(signed_props_canonical)

      signed_info_canonical = build_signed_info_canonical(
        sig_props_id, alg[:algorithm_uri], document_digest, signed_props_digest
      )
      signature_value = alg[:sign].call(signed_info_canonical)

      assemble_document(
        challenge:         challenge,
        nip:               nip,
        sig_id:            sig_id,
        sig_props_id:      sig_props_id,
        algorithm_uri:     alg[:algorithm_uri],
        document_digest:   document_digest,
        signed_props_digest: signed_props_digest,
        signature_value:   signature_value,
        cert_der_base64:   cert_der_base64,
        cert_digest:       cert_digest,
        issuer_dn:         issuer_dn,
        serial_number:     serial_number,
        signing_time:      signing_time
      )
    end

    def self.pem_to_der_base64(pem)
      pem.each_line
         .map(&:strip)
         .reject { |l| l.empty? || l.start_with?("-----") }
         .join
    end

    def self.sha256_b64(data)
      Base64.strict_encode64(OpenSSL::Digest::SHA256.digest(data))
    end

    def self.key_info(private_key_pem, passphrase)
      pkey =
        if passphrase && !passphrase.empty?
          OpenSSL::PKey.read(private_key_pem, passphrase)
        else
          OpenSSL::PKey.read(private_key_pem)
        end

      case pkey
      when OpenSSL::PKey::RSA
        {
          algorithm_uri: RSA_SHA256_SIG,
          sign: ->(data) {
            Base64.strict_encode64(pkey.sign(OpenSSL::Digest::SHA256.new, data))
          }
        }
      when OpenSSL::PKey::EC
        curve = pkey.group.curve_name
        if %w[prime256v1 P-256].include?(curve)
          alg_uri = ECDSA_SHA256_SIG; digest = OpenSSL::Digest::SHA256; coord_len = 32
        elsif %w[secp384r1 P-384].include?(curve)
          alg_uri = ECDSA_SHA384_SIG; digest = OpenSSL::Digest::SHA384; coord_len = 48
        else
          alg_uri = ECDSA_SHA512_SIG; digest = OpenSSL::Digest::SHA512; coord_len = 66
        end
        {
          algorithm_uri: alg_uri,
          sign: ->(data) {
            der = pkey.sign(digest.new, data)
            Base64.strict_encode64(ec_der_to_raw(der, coord_len))
          }
        }
      else
        raise Ksef::Client::Error.new("unsupported KSeF signing key type: #{pkey.class}")
      end
    end

    def self.ec_der_to_raw(der, coord_len)
      seq = OpenSSL::ASN1.decode(der)
      raise Ksef::Client::Error.new("invalid ECDSA DER signature") unless seq.is_a?(OpenSSL::ASN1::Sequence)
      r = seq.value[0].value.to_s(2)
      s = seq.value[1].value.to_s(2)
      pad(r, coord_len) + pad(s, coord_len)
    end

    def self.pad(bytes, len)
      return bytes[-len, len] if bytes.bytesize > len
      return bytes if bytes.bytesize == len
      ("\x00".b * (len - bytes.bytesize)) + bytes
    end

    def self.build_auth_request_canonical(challenge, nip)
      "<AuthTokenRequest xmlns=\"#{KSEF_AUTH_NS}\">" \
        "<Challenge>#{esc_xml(challenge)}</Challenge>" \
        "<ContextIdentifier><Nip>#{esc_xml(nip)}</Nip></ContextIdentifier>" \
        "<SubjectIdentifierType>certificateSubject</SubjectIdentifierType>" \
        "</AuthTokenRequest>"
    end

    def self.build_signed_props_canonical(sig_props_id, signing_time, cert_digest, issuer_dn, serial_number)
      "<xades:SignedProperties xmlns=\"#{KSEF_AUTH_NS}\" xmlns:ds=\"#{DS_NS}\" xmlns:xades=\"#{XADES_NS}\" Id=\"#{esc_attr(sig_props_id)}\">" \
        "<xades:SignedSignatureProperties>" \
          "<xades:SigningTime>#{esc_xml(signing_time)}</xades:SigningTime>" \
          "<xades:SigningCertificate>" \
            "<xades:Cert>" \
              "<xades:CertDigest>" \
                "<ds:DigestMethod Algorithm=\"#{esc_attr(SHA256_DIGEST)}\"></ds:DigestMethod>" \
                "<ds:DigestValue>#{cert_digest}</ds:DigestValue>" \
              "</xades:CertDigest>" \
              "<xades:IssuerSerial>" \
                "<ds:X509IssuerName>#{esc_xml(issuer_dn)}</ds:X509IssuerName>" \
                "<ds:X509SerialNumber>#{esc_xml(serial_number)}</ds:X509SerialNumber>" \
              "</xades:IssuerSerial>" \
            "</xades:Cert>" \
          "</xades:SigningCertificate>" \
        "</xades:SignedSignatureProperties>" \
      "</xades:SignedProperties>"
    end

    def self.build_signed_info_canonical(sig_props_id, algorithm_uri, document_digest, signed_props_digest)
      "<ds:SignedInfo xmlns=\"#{KSEF_AUTH_NS}\" xmlns:ds=\"#{DS_NS}\">" \
        "<ds:CanonicalizationMethod Algorithm=\"#{esc_attr(C14N)}\"></ds:CanonicalizationMethod>" \
        "<ds:SignatureMethod Algorithm=\"#{esc_attr(algorithm_uri)}\"></ds:SignatureMethod>" \
        "<ds:Reference URI=\"\">" \
          "<ds:Transforms>" \
            "<ds:Transform Algorithm=\"#{esc_attr(ENVELOPED_SIG)}\"></ds:Transform>" \
          "</ds:Transforms>" \
          "<ds:DigestMethod Algorithm=\"#{esc_attr(SHA256_DIGEST)}\"></ds:DigestMethod>" \
          "<ds:DigestValue>#{document_digest}</ds:DigestValue>" \
        "</ds:Reference>" \
        "<ds:Reference Type=\"#{esc_attr(XADES_SIGNED_PROPS_TYPE)}\" URI=\"##{esc_attr(sig_props_id)}\">" \
          "<ds:DigestMethod Algorithm=\"#{esc_attr(SHA256_DIGEST)}\"></ds:DigestMethod>" \
          "<ds:DigestValue>#{signed_props_digest}</ds:DigestValue>" \
        "</ds:Reference>" \
      "</ds:SignedInfo>"
    end

    def self.assemble_document(challenge:, nip:, sig_id:, sig_props_id:, algorithm_uri:,
                               document_digest:, signed_props_digest:, signature_value:,
                               cert_der_base64:, cert_digest:, issuer_dn:, serial_number:,
                               signing_time:)
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" \
      "<AuthTokenRequest xmlns=\"#{KSEF_AUTH_NS}\">" \
        "<Challenge>#{esc_xml(challenge)}</Challenge>" \
        "<ContextIdentifier><Nip>#{esc_xml(nip)}</Nip></ContextIdentifier>" \
        "<SubjectIdentifierType>certificateSubject</SubjectIdentifierType>" \
        "<ds:Signature xmlns:ds=\"#{DS_NS}\" Id=\"#{esc_attr(sig_id)}\">" \
          "<ds:SignedInfo>" \
            "<ds:CanonicalizationMethod Algorithm=\"#{esc_attr(C14N)}\"></ds:CanonicalizationMethod>" \
            "<ds:SignatureMethod Algorithm=\"#{esc_attr(algorithm_uri)}\"></ds:SignatureMethod>" \
            "<ds:Reference URI=\"\">" \
              "<ds:Transforms>" \
                "<ds:Transform Algorithm=\"#{esc_attr(ENVELOPED_SIG)}\"></ds:Transform>" \
              "</ds:Transforms>" \
              "<ds:DigestMethod Algorithm=\"#{esc_attr(SHA256_DIGEST)}\"></ds:DigestMethod>" \
              "<ds:DigestValue>#{document_digest}</ds:DigestValue>" \
            "</ds:Reference>" \
            "<ds:Reference Type=\"#{esc_attr(XADES_SIGNED_PROPS_TYPE)}\" URI=\"##{esc_attr(sig_props_id)}\">" \
              "<ds:DigestMethod Algorithm=\"#{esc_attr(SHA256_DIGEST)}\"></ds:DigestMethod>" \
              "<ds:DigestValue>#{signed_props_digest}</ds:DigestValue>" \
            "</ds:Reference>" \
          "</ds:SignedInfo>" \
          "<ds:SignatureValue>#{signature_value}</ds:SignatureValue>" \
          "<ds:KeyInfo>" \
            "<ds:X509Data>" \
              "<ds:X509Certificate>#{cert_der_base64}</ds:X509Certificate>" \
            "</ds:X509Data>" \
          "</ds:KeyInfo>" \
          "<ds:Object>" \
            "<xades:QualifyingProperties xmlns:xades=\"#{XADES_NS}\" Target=\"##{esc_attr(sig_id)}\">" \
              "<xades:SignedProperties Id=\"#{esc_attr(sig_props_id)}\">" \
                "<xades:SignedSignatureProperties>" \
                  "<xades:SigningTime>#{esc_xml(signing_time)}</xades:SigningTime>" \
                  "<xades:SigningCertificate>" \
                    "<xades:Cert>" \
                      "<xades:CertDigest>" \
                        "<ds:DigestMethod Algorithm=\"#{esc_attr(SHA256_DIGEST)}\"></ds:DigestMethod>" \
                        "<ds:DigestValue>#{cert_digest}</ds:DigestValue>" \
                      "</xades:CertDigest>" \
                      "<xades:IssuerSerial>" \
                        "<ds:X509IssuerName>#{esc_xml(issuer_dn)}</ds:X509IssuerName>" \
                        "<ds:X509SerialNumber>#{esc_xml(serial_number)}</ds:X509SerialNumber>" \
                      "</xades:IssuerSerial>" \
                    "</xades:Cert>" \
                  "</xades:SigningCertificate>" \
                "</xades:SignedSignatureProperties>" \
              "</xades:SignedProperties>" \
            "</xades:QualifyingProperties>" \
          "</ds:Object>" \
        "</ds:Signature>" \
      "</AuthTokenRequest>"
    end

    def self.esc_xml(str)
      str.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
    end

    def self.esc_attr(str)
      str.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub('"', "&quot;")
    end

    # Matches the TS reference: join cert.issuer RDNs with ", " in REVERSED order
    # (RFC 2253 reversal), using Ruby's X509::Name#to_a forward-ordered output.
    def self.format_dn(name)
      name.to_a.map { |rdn| "#{rdn[0]}=#{rdn[1]}" }.reverse.join(", ")
    end
  end
end
