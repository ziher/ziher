require "net/http"
require "json"
require "uri"

module Ksef
  class Client
    class Error < StandardError; end

    OPEN_TIMEOUT = 10
    READ_TIMEOUT = 30
    MAX_RETRIES  = 3

    def initialize(base_url:)
      @base_url = base_url
    end

    def get(path, headers: {})
      request(Net::HTTP::Get, path, nil, headers)
    end

    def post(path, body, headers: {})
      request(Net::HTTP::Post, path, body, headers)
    end

    def get_raw(path, headers: {})
      uri = URI.join(@base_url, path)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                      open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
        req = Net::HTTP::Get.new(uri.request_uri)
        headers.each { |k, v| req[k] = v }
        res = http.request(req)
        raise Error, "GET #{path} failed: #{res.code}" unless res.code.to_i.between?(200, 299)
        return res.body
      end
    end

    private

    def request(verb_class, path, body, headers, attempt: 0)
      uri = URI.join(@base_url, path)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                      open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
        req = verb_class.new(uri.request_uri)
        req["Content-Type"] = "application/json"
        headers.each { |k, v| req[k] = v }
        req.body = body.to_json if body

        res = http.request(req)

        if res.code.to_i == 429 && attempt < MAX_RETRIES
          delay = res["Retry-After"].to_i
          sleep(delay) if delay > 0
          return request(verb_class, path, body, headers, attempt: attempt + 1)
        end

        unless res.code.to_i.between?(200, 299)
          raise Error, "#{verb_class.name.split('::').last} #{path} → HTTP #{res.code}: #{res.body}"
        end

        res.body.to_s.empty? ? {} : JSON.parse(res.body)
      end
    end
  end
end
