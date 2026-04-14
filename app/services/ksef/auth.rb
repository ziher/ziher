module Ksef
  module Auth
    def self.access_token(setting)
      client = Ksef::Client.new(base_url: setting.api_url)

      challenge_response = client.post("/auth/challenge", { contextIdentifier: { type: "nip", identifier: setting.nip } })
      challenge = challenge_response.fetch("challenge")

      signed = sign(challenge, setting.key_pem)

      session_response = client.post("/auth/sessions", {
        challenge: challenge,
        identifier: { type: "nip", identifier: setting.nip },
        authorisationScope: { type: "list", elements: [{ type: "Subject2" }] },
        signature: signed
      })

      session_response.dig("accessToken", "token") || raise(Ksef::Client::Error, "missing accessToken in /auth/sessions response")
    end

    def self.sign(challenge, key_pem)
      rsa = OpenSSL::PKey::RSA.new(key_pem)
      Base64.strict_encode64(rsa.sign(OpenSSL::Digest.new("SHA256"), challenge))
    end
  end
end
