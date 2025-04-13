# frozen_string_literal: true
# typed: strict

require "nokogiri"
require_relative "base_parser"

module DataGoKr
  class ListParseResult < T::Struct
    const :items, T::Array[T::Hash[Symbol, T.untyped]]
    const :total_count, Integer
    const :num_of_rows, Integer
    const :page_no, Integer
  end

  class ListApiParser < BaseParser
    extend T::Sig
    extend T::Helpers
    abstract!


    # 단일 <item>을 파싱하는 메서드. 하위 클래스에서 구현 필요
    sig { abstract.params(item_element: Nokogiri::XML::Element).returns(T::Hash[Symbol, T.untyped]) }
    def parse_item(item_element); end

    # 법안 리스트 XPath
    sig { returns(String) }
    def items_xpath
      "//response/body/items/item"
    end

    # 전체 레코드 수의 XPath
    sig { returns(String) }
    def total_count_xpath
      "//response/body/totalCount"
    end

    # 응답의 item 수의 XPath
    sig { returns(String) }
    def num_of_rows_xpath
      "//response/body/numOfRows"
    end

    # 페이지 번호의 XPath
    sig { returns(String) }
    def page_no_xpath
      "//response/body/pageNo"
    end

    sig { params(xml_string: String).returns(ListParseResult) }
    def parse(xml_string)
      doc = parse_and_validate_header(xml_string)

      item_elements = doc.xpath(items_xpath)
      parsed_items = T.let([], T::Array[T::Hash[Symbol, T.untyped]])
      item_elements.each do |element|
        # Call the abstract parse_item method implemented by the subclass
        parsed_items << parse_item(element)
      end

      total_count = extract_integer(doc, total_count_xpath)
      num_of_rows = extract_integer(doc, num_of_rows_xpath)
      page_no = extract_integer(doc, page_no_xpath)

      ListParseResult.new(
        items: parsed_items,
        total_count: total_count,
        num_of_rows: num_of_rows,
        page_no: page_no
      )
    end

    sig {
      params(
        total_count: T.nilable(Integer),
        num_of_rows: T.nilable(Integer)
      )
      .returns(Integer) # Returns 1 if pagination info is missing
    }
    def calculate_total_pages(total_count, num_of_rows)
      # Return 1 if essential pagination info is missing
      return 1 unless total_count && num_of_rows

      # Ensure num_of_rows is positive to avoid division by zero or infinite loops
      rows = [ num_of_rows, 1 ].max
      (total_count.to_f / rows).ceil
    end

    private

    # Helper method for parsing date within this parser
    sig { params(date_string: T.nilable(String)).returns(T.nilable(ActiveSupport::TimeWithZone)) }
    def parse_xml_date(date_string)
      return nil if date_string.blank?
      begin
        # Ensure it becomes a DateTime object then Rails TimeWithZone
        Date.parse(date_string).to_datetime.in_time_zone
      rescue ArgumentError
        nil
      end
    end

    # Helper to extract an integer from a given XPath
    sig { params(doc: Nokogiri::XML::Document, xpath: String).returns(Integer) }
    def extract_integer(doc, xpath)
      element = doc.at_xpath(xpath)
      raise ApiError, "Element not found for XPath: #{xpath}" unless element
      element.text.to_i
    end
  end
end
