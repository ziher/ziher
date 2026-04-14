module Ksef
  module PublicKey
    CACHE_KEY = "ksef:mf_public_key".freeze
    TTL = 24.hours

    def self.fetch(client)
      Rails.cache.fetch(CACHE_KEY, expires_in: TTL) do
        response = client.get("/auth/public-key")
        response.fetch("publicKey")
      end
    end
  end
end
