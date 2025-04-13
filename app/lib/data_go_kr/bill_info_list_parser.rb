# frozen_string_literal: true
# typed: strict

require "nokogiri"
require "date"
require_relative "list_api_parser"

module DataGoKr
  class BillInfoListParser < ListApiParser
    extend T::Sig

    sig { override.params(item_element: Nokogiri::XML::Element).returns(T::Hash[Symbol, T.untyped]) }
    def parse_item(item_element)
      assembly_bill_id = item_element.at_xpath("billId")&.text
      # PK값이 없으면 빈 해시 반환
      return {} if assembly_bill_id.blank?

      propose_dt_str = item_element.at_xpath("proposeDt")&.text

      {
        assembly_bill_id: assembly_bill_id,
        title: item_element.at_xpath("billName")&.text,
        bill_number: item_element.at_xpath("billNo")&.text,
        summary: item_element.at_xpath("summary")&.text,
        proposed_at: parse_xml_date(propose_dt_str),
        bill_stage: item_element.at_xpath("procStageCd")&.text
      }.compact # Remove nil values
    end
  end
end
