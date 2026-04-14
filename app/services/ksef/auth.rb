module Ksef
  module Auth
    POLL_INTERVAL = 3
    POLL_TIMEOUT  = 60

    # Returns a JWT access token after performing the KSeF v2 cert-based
    # authentication flow: /auth/challenge → XAdES-signed /auth/xades-signature
    # → poll /auth/{ref} → /auth/token/redeem.
    def self.access_token(setting)
      client = Ksef::Client.new(base_url: setting.api_url)

      challenge_resp = client.post(
        "/auth/challenge",
        { contextIdentifier: { type: "Nip", value: setting.nip } }
      )
      challenge = challenge_resp.fetch("challenge")

      signed_xml = Ksef::Xades.build_auth_document(
        challenge: challenge,
        nip: setting.nip,
        cert_pem: setting.cert_pem,
        private_key_pem: setting.key_pem,
        passphrase: setting.key_passphrase.presence
      )

      xades_resp = client.post_xml("/auth/xades-signature", signed_xml)
      reference_number      = xades_resp.fetch("referenceNumber")
      authentication_token  = xades_resp.dig("authenticationToken", "token") ||
        raise(Ksef::Client::Error.new("missing authenticationToken in /auth/xades-signature response"))

      poll_auth_status(client, reference_number, authentication_token)

      redeem_resp = client.post(
        "/auth/token/redeem",
        {},
        access_token: authentication_token
      )
      redeem_resp.dig("accessToken", "token") ||
        raise(Ksef::Client::Error.new("missing accessToken in /auth/token/redeem response"))
    end

    def self.poll_auth_status(client, reference_number, authentication_token)
      deadline = Time.now + POLL_TIMEOUT
      loop do
        status = client.get("/auth/#{reference_number}", access_token: authentication_token)
        code = status.dig("status", "code").to_i
        return if code == 200
        if code >= 400
          raise Ksef::Client::Error.new(
            "KSeF auth verification failed: #{code} #{status.dig('status', 'description')}"
          )
        end
        raise Ksef::Client::Error.new("KSeF auth verification timeout") if Time.now > deadline
        sleep POLL_INTERVAL
      end
    end
  end
end
