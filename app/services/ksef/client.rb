require "net/http"
require "json"
require "uri"

module Ksef
  class Client
    class Error < StandardError
      attr_reader :status, :body
      def initialize(message, status: nil, body: nil)
        super(message)
        @status = status
        @body = body
      end
    end

    OPEN_TIMEOUT = 10
    READ_TIMEOUT = 30
    MAX_RETRIES  = 3
    API_PREFIX   = "/v2".freeze

    def initialize(base_url:)
      @base_url = base_url.to_s.chomp("/")
    end

    def get(path, headers: {}, access_token: nil)
      request(Net::HTTP::Get, path, body: nil, headers: headers, access_token: access_token)
    end

    def post(path, body, headers: {}, access_token: nil)
      request(Net::HTTP::Post, path, body: body, headers: headers, access_token: access_token)
    end

    def post_xml(path, xml_body, access_token: nil)
      request(Net::HTTP::Post, path,
              body: xml_body, headers: { "Content-Type" => "application/xml", "Accept" => "application/json" },
              access_token: access_token, raw_body: true)
    end

    def get_binary(absolute_url)
      uri = URI.parse(absolute_url)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                      open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
        req = Net::HTTP::Get.new(uri.request_uri)
        req["Accept"] = "application/octet-stream"
        res = http.request(req)
        unless res.code.to_i.between?(200, 299)
          raise Error.new("GET #{absolute_url} → HTTP #{res.code}: #{friendly_error(res.body)}",
                          status: res.code.to_i, body: res.body)
        end
        return res.body
      end
    end

    private

    def request(verb_class, path, body:, headers:, access_token:, raw_body: false, attempt: 0)
      full_path = "#{API_PREFIX}#{path}"
      uri = URI.join("#{@base_url}/", full_path.sub(%r{\A/}, ""))

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                      open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
        req = verb_class.new(uri.request_uri)
        req["Accept"] = "application/json"
        req["Content-Type"] = raw_body ? (headers["Content-Type"] || "application/xml") : "application/json"
        headers.each { |k, v| req[k] = v }
        req["Authorization"] = "Bearer #{access_token}" if access_token

        if body
          req.body = raw_body ? body : body.to_json
        end

        res = http.request(req)

        if res.code.to_i == 429 && attempt < MAX_RETRIES
          delay = res["Retry-After"].to_i
          sleep(delay) if delay > 0
          return request(verb_class, path, body: body, headers: headers, access_token: access_token,
                         raw_body: raw_body, attempt: attempt + 1)
        end

        unless res.code.to_i.between?(200, 299)
          raise Error.new("#{verb_class.name.split('::').last} #{full_path} → HTTP #{res.code}: #{friendly_error(res.body)}",
                          status: res.code.to_i, body: res.body)
        end

        res.body.to_s.empty? ? {} : JSON.parse(res.body)
      end
    end

    def friendly_error(body)
      return "" if body.to_s.empty?
      json = JSON.parse(body) rescue nil
      return body.to_s[0, 1500] unless json.is_a?(Hash)

      details = json.dig("exception", "exceptionDetailList")
      return body.to_s[0, 1500] unless details.is_a?(Array) && details.any?

      details.map do |d|
        code  = d["exceptionCode"]
        desc  = d["exceptionDescription"]
        extra = Array(d["details"]).join("; ")
        [code && "[#{code}]", desc, extra.presence].compact.join(" ").strip
      end.reject(&:empty?).join(" | ")
    rescue StandardError
      body.to_s[0, 1500]
    end
  end
end
