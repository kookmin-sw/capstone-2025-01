# frozen_string_literal: true
# typed: strict

require "nokogiri"
require_relative "../api_client" # Use ApiClient errors

module DataGoKr
  class BaseParser
    extend T::Sig

    include ApiClient # Include to use error classes directly

    SUCCESS_RESULT_CODE = T.let("00".freeze, String)

    sig { params(xml_string: String).returns(Nokogiri::XML::Document) }
    def parse_and_validate_header(xml_string)
      begin
        doc = T.let(Nokogiri::XML(xml_string), Nokogiri::XML::Document)
      rescue Nokogiri::XML::SyntaxError => e
        raise ApiError, "Failed to parse XML response: #{e.message}"
      end

      validate_header(doc) # Validate common header first
      doc
    end

    private

    sig { params(doc: Nokogiri::XML::Document).void }
    def validate_header(doc)
      result_code = doc.at_xpath("//response/header/resultCode")&.text

      return if result_code == SUCCESS_RESULT_CODE

      error_message = "API Error: #{doc.text.strip}"

      raise ApiError, error_message
    end
  end
end
