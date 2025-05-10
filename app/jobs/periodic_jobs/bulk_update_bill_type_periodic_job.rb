# frozen_string_literal: true
# typed: true

require "net/http"
require "uri"
require "date"

require_relative "../../lib/api_client"
require_relative "../../lib/data_go_kr/bill_info_list_parser"
require_relative "../concerns/bulk_upsertable"
require_relative "../../models/concerns/bill_types"

module PeriodicJobs
  class BulkUpdateBillTypePeriodicJob < ApplicationJob
    extend T::Sig
    include ApiClient
    include BulkUpsertable
    include BillTypes

    queue_as :default

    API_BASE_URL = URI::HTTP.build(host: "apis.data.go.kr", path: "/9710000/BillInfoService2/getBillInfoList")
    ROWS_PER_PAGE = 1000
    MODEL_CLASS = Bill
    DEFAULT_START_ORD = 22
    DEFAULT_END_ORD = 22
    DEFAULT_SLEEP_SECONDS = 10.0

    class ApiError < StandardError; end
    class AuthenticationError < ApiError; end
    class TransientError < ApiError; end

    sig { params(start_ord: T.nilable(Integer), end_ord: T.nilable(Integer), sleep_seconds: T.nilable(Float)).void }
    def perform(start_ord = nil, end_ord = nil, sleep_seconds = nil)
      parser = DataGoKr::BillInfoListParser.new
      service_key = get_service_key
      start_ord = start_ord || Settings.bills&.start_ord || DEFAULT_START_ORD
      end_ord = end_ord || Settings.bills&.end_ord || DEFAULT_END_ORD
      sleep_seconds = sleep_seconds || Settings.bills&.api_sleep_seconds || DEFAULT_SLEEP_SECONDS

      BillTypes::LIST.each do |bill_kind_cd, bill_type_value|
        page_no = 1
        total_pages = T.let(1, Integer)
        has_pagination = T.let(true, T::Boolean)
        Rails.logger.info("Processing bills of type '#{bill_type_value}'...")
        loop do
          log_message = "[BillType: #{bill_type_value}] Processing page #{page_no}..."
          Rails.logger.info(log_message)
          url = build_api_url(service_key, start_ord, end_ord, page_no, bill_kind_cd)
          begin
            response_body = ApiClient.fetch_with_retry(url)
            parse_result = parser.parse(response_body)
            items_data = parse_result.items
            Rails.logger.debug { "[BillType: #{bill_type_value}] Parsed #{items_data.count} items." }
            # Set bill_type for all items
            items_data.each { |item| item[:bill_type] = bill_type_value }
            records_to_upsert = prepare_records_for_upsert(items_data)
            bulk_upsert(
              records_to_upsert,
              MODEL_CLASS,
              conflict_target: [ :assembly_bill_id ],
              update_columns: [ :bill_type ],
              silence: true
            )
            if page_no == 1
              total_pages = parser.calculate_total_pages(parse_result.total_count, parse_result.num_of_rows)
              has_pagination = total_pages > 1
              if has_pagination
                Rails.logger.info "[BillType: #{bill_type_value}] Total: #{parse_result.total_count}, Total pages: #{total_pages}"
              else
                Rails.logger.info "[BillType: #{bill_type_value}] Pagination info missing or only one page."
              end
            end
          rescue ApiClient::AuthenticationError => e
            Rails.logger.error "[BillType: #{bill_type_value}] Authentication error: #{e.message}. Check service key."
            raise
          rescue ApiClient::TransientError => e
            Rails.logger.error "[BillType: #{bill_type_value}] Transient error after retries: #{e.message}"
            raise
          rescue ApiClient::ApiError => e
            Rails.logger.error "[BillType: #{bill_type_value}] API or Parsing error: #{e.message}"
            raise
          rescue StandardError => e
            Rails.logger.error "[BillType: #{bill_type_value}] Unexpected error: #{e.message}\n#{e.backtrace&.join("\n")}"
            raise
          end

          break unless has_pagination
          break if page_no >= total_pages
          page_no += 1
          if sleep_seconds > 0 && page_no <= total_pages
            Rails.logger.debug { "[BillType: #{bill_type_value}] Sleeping for #{sleep_seconds} seconds before next API call." }
            sleep(sleep_seconds)
          end
        end
        Rails.logger.info("[BillType: #{bill_type_value}] Finished updating bills of type '#{bill_type_value}'.")
      end
      Rails.logger.info "Finished updating all bill types."
    end

    private

    sig { returns(String) }
    def get_service_key
      service_key = Rails.application.credentials.data_go_kr.bill_info_service_key
      unless service_key
        msg = "Service key not configured."
        Rails.logger.error msg
        raise ArgumentError, msg
      end
      service_key
    end

    sig { params(service_key: String, start_ord: Integer, end_ord: Integer, page_no: Integer, bill_kind_cd: Symbol).returns(URI::HTTP) }
    def build_api_url(service_key, start_ord, end_ord, page_no, bill_kind_cd)
      uri = API_BASE_URL.dup
      uri.query = URI.encode_www_form({
        serviceKey: service_key,
        start_ord: start_ord,
        end_ord: end_ord,
        pageNo: page_no,
        numOfRows: ROWS_PER_PAGE,
        bill_kind_cd: bill_kind_cd.to_s
      })
      uri
    end

    sig { params(items_data: T::Array[T::Hash[Symbol, T.untyped]]).returns(T::Array[Bill]) }
    def prepare_records_for_upsert(items_data)
      assembly_bill_ids = items_data.map { |item| item[:assembly_bill_id] }.compact.uniq
      existing_records = MODEL_CLASS.where(assembly_bill_id: assembly_bill_ids).index_by(&:assembly_bill_id)
      records = []

      items_data.each do |item_attributes|
        next if item_attributes.empty?
        assembly_bill_id = item_attributes[:assembly_bill_id]
        next if assembly_bill_id.blank?

        record = existing_records[assembly_bill_id] || MODEL_CLASS.new(assembly_bill_id: assembly_bill_id)
        record.assign_attributes(item_attributes)
        records << record if record.new_record? || record.changed?
      end
      Rails.logger.debug { "Prepared #{records.count} records for upsert." }
      records
    end
  end
end
