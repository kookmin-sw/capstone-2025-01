# frozen_string_literal: true
# typed: strict

require "net/http"
require "uri"

module ApiClient
  extend T::Sig

  class ApiError < StandardError; end
  class AuthenticationError < ApiError; end
  class TransientError < ApiError; end

  DEFAULT_MAX_RETRIES = 3
  DEFAULT_INITIAL_RETRY_DELAY = 5 # seconds
  DEFAULT_HEADERS = T.let({
    "Accept": "application/xml",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36"
  }.freeze, T::Hash[String, String])

  sig {
    params(
      uri: URI::HTTP,
      headers: T::Hash[String, String],
      max_retries: Integer,
      initial_delay: Integer
    )
    .returns(String)
  }
  def self.fetch_with_retry(uri, headers: DEFAULT_HEADERS, max_retries: DEFAULT_MAX_RETRIES, initial_delay: DEFAULT_INITIAL_RETRY_DELAY)
    retries = 0
    delay = initial_delay
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      request = Net::HTTP::Get.new(uri.request_uri)
      headers.each { |key, value| request[key] = value }

      response = T.let(http.request(request), Net::HTTPResponse)

      case response
      when Net::HTTPSuccess
        T.let(response.body, String)
      when Net::HTTPUnauthorized, Net::HTTPForbidden
        raise AuthenticationError, "HTTP #{response.code}: #{response.message}"
      when Net::HTTPServerError # 5xx errors, potentially transient
        raise TransientError, "HTTP #{response.code}: #{response.message}"
      else # Other client errors (4xx) or unexpected responses
        raise ApiError, "HTTP #{response.code}: #{response.message}"
      end
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, Errno::ECONNREFUSED => e
      # These are typically transient network issues
      raise TransientError, "Network error: #{e.class} - #{e.message}"
    rescue TransientError => e
      if retries < max_retries
        retries += 1
        Rails.logger.warn "Transient error encountered (#{e.message}). Retrying in #{delay} seconds... (#{retries}/#{max_retries})"
        sleep delay
        delay *= 2 # Exponential backoff
        retry
      else
        Rails.logger.error "Max retries reached for transient error: #{e.message}"
        raise
      end
    rescue StandardError => e
       Rails.logger.error "Unexpected standard error during fetch: #{e.class} - #{e.message}"
       raise ApiError, "Unexpected error during fetch: #{e.message}" # Wrap in ApiError or re-raise
    end
  end
end
