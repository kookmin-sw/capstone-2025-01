# frozen_string_literal: true
# typed: strict

require "nokogiri"
require_relative "list_api_parser"

module DataGoKr
  class BillRecentMoorListParser < ListApiParser
    extend T::Sig

    sig { override.params(item_element: Nokogiri::XML::Element).returns(T::Hash[Symbol, String]) }
    def parse_item(item_element)
      # NOTE: /getBillInfoList의 billId와 다르게 billid로 되어 있음
      assembly_bill_id = item_element.at_xpath("billid")&.text
      # PK값이 없으면 빈 해시 반환
      return {} if assembly_bill_id.blank?

      # 계류의안의 경우 회부일, 소관위원회가 없을 수 있음
      committee_name = item_element.at_xpath("committeename")&.text&.strip
      submit_dt_str = item_element.at_xpath("submitdt")&.text

      {
        assembly_bill_id: assembly_bill_id,
        title: item_element.at_xpath("billname")&.text,
        bill_number: item_element.at_xpath("billno")&.text,
        proposer_text: item_element.at_xpath("proposer")&.text,
        proposer_kind: item_element.at_xpath("proposerkind")&.text,
        proposed_at: parse_xml_date(item_element.at_xpath("proposedt")&.text),
        submitted_at: parse_xml_date(submit_dt_str),
        committee_name: committee_name
      }.compact
    end
  end
end
