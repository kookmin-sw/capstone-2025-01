# frozen_string_literal: true
# typed: strict

require "nokogiri"
require "date"
require_relative "list_api_parser"

module DataGoKr
  class BillJsictionComiteProcessListParser < ListApiParser
    extend T::Sig

    sig { override.params(item_element: Nokogiri::XML::Element).returns(T::Hash[Symbol, T.untyped]) }
    def parse_item(item_element)
      assembly_bill_id = item_element.at_xpath("billId")&.text
      # PK값이 없으면 빈 해시 반환
      return {} if assembly_bill_id.blank?

      propose_dt_str = item_element.at_xpath("proposeDt")&.text
      proc_dt_str = item_element.at_xpath("procDt")&.text
      submit_dt_str = item_element.at_xpath("submitDt")&.text

      {
        assembly_bill_id: assembly_bill_id,
        title: item_element.at_xpath("billName")&.text,
        bill_number: item_element.at_xpath("billNo")&.text,
        proposer_text: item_element.at_xpath("proposer")&.text, # Nilable
        proposer_kind: item_element.at_xpath("proposerKind")&.text,
        proposed_at: parse_xml_date(propose_dt_str),
        submitted_at: parse_xml_date(submit_dt_str), # Nilable
        committee_name: item_element.at_xpath("committeeName")&.text,
        processed_at: parse_xml_date(proc_dt_str),
        process_result: item_element.at_xpath("generalResult")&.text
      }.compact
    end
  end
end
