# frozen_string_literal: true
# typed: true

require "net/http"
require "uri"
require "date"

require_relative "../../lib/api_client"
require_relative "../../lib/data_go_kr/bill_info_list_parser"
require_relative "../concerns/bulk_upsertable"

module PeriodicJobs
  class BulkUpdateBillInfoPeriodicJob < ApplicationJob
    extend T::Sig
    include ApiClient
    include BulkUpsertable

    queue_as :default

    # 의안 목록 검색 API
    API_BASE_URL = T.let(URI::HTTP.build(host: "apis.data.go.kr", path: "/9710000/BillInfoService2/getBillInfoList"), URI::HTTP)

    ROWS_PER_PAGE = 1000
    MODEL_CLASS = T.let(Bill, T.class_of(ActiveRecord::Base))

    # 의회 대수 기본값
    DEFAULT_START_ORD = 22
    DEFAULT_END_ORD = 22

    DEFAULT_SLEEP_SECONDS = 10.0

    class ApiError < StandardError; end
    class AuthenticationError < ApiError; end
    class TransientError < ApiError; end


    sig { params(start_ord: T.nilable(Integer), end_ord: T.nilable(Integer), sleep_seconds: T.nilable(Float)).void }
    def perform(start_ord = nil, end_ord = nil, sleep_seconds = nil)
      parser = DataGoKr::BillInfoListParser.new

      page_no = 1
      total_pages = 1
      has_pagination = T.let(true, T::Boolean)

      service_key = get_service_key()
      start_ord_setting = T.let(Settings.bills&.start_ord, T.nilable(Integer))
      end_ord_setting = T.let(Settings.bills&.end_ord, T.nilable(Integer))
      sleep_setting = T.let(Settings.bills&.api_sleep_seconds, T.nilable(Float))

      start_ord = start_ord || start_ord_setting || DEFAULT_START_ORD
      end_ord = end_ord || end_ord_setting || DEFAULT_END_ORD
      sleep_seconds = sleep_seconds || sleep_setting || DEFAULT_SLEEP_SECONDS

      loop do
        log_message = "Processing #{T.must(MODEL_CLASS.name).pluralize}..."
        log_message = "Processing page #{page_no} of #{T.must(MODEL_CLASS.name).pluralize}..." if has_pagination && page_no > 1
        Rails.logger.info(log_message)

        url = build_api_url(service_key, start_ord, end_ord, page_no)

        begin
          response_body = ApiClient.fetch_with_retry(url)
          parse_result = parser.parse(response_body)
          items_data = T.let(parse_result.items, T::Array[T::Hash[Symbol, T.untyped]])
          Rails.logger.debug { "Parsed #{items_data.count} items." }

          records_to_upsert = prepare_records_for_upsert(items_data)
          bulk_upsert(
            records_to_upsert,
            MODEL_CLASS,
            conflict_target: [ :assembly_bill_id ],
            update_columns: [ :title, :bill_number, :summary, :proposed_at, :bill_stage ],
            silence: true
          )
          if page_no == 1
            # Call the parser's method to calculate total pages
            total_pages = parser.calculate_total_pages(parse_result.total_count, parse_result.num_of_rows)
            has_pagination = total_pages > 1
            if has_pagination
              Rails.logger.info "Total #{T.must(MODEL_CLASS.name).pluralize}: #{parse_result.total_count}, Total pages: #{total_pages}"
            else
              Rails.logger.info "Pagination info missing or only one page."
            end
          end

        rescue ApiClient::AuthenticationError => e
          Rails.logger.error "Authentication error fetching #{T.must(MODEL_CLASS.name).pluralize}: #{e.message}. Check service key."
          raise
        rescue ApiClient::TransientError => e
          Rails.logger.error "Transient error fetching/parsing #{T.must(MODEL_CLASS.name).pluralize} after retries: #{e.message}"
          raise
        rescue ApiClient::ApiError => e
          Rails.logger.error "API or Parsing error fetching/processing #{T.must(MODEL_CLASS.name).pluralize}: #{e.message}"
          raise
        rescue StandardError => e
          Rails.logger.error "Unexpected error processing page #{page_no} for #{MODEL_CLASS.name}: #{e.message}\n#{T.must(e.backtrace).join("\n")}"
          raise
        end

        break unless has_pagination
        break if page_no >= total_pages
        page_no += 1

        # Sleep between API calls to avoid rate limiting
        if sleep_seconds > 0 && page_no <= total_pages
          Rails.logger.debug { "Sleeping for #{sleep_seconds} seconds before next API call." }
          sleep(sleep_seconds)
        end
      end

      Rails.logger.info "Finished updating #{T.must(MODEL_CLASS.name).pluralize}."
    end

    private

    sig { returns(String) }
    def get_service_key
      service_key = Rails.application.credentials.data_go_kr.bill_info_service_key
      unless service_key
        msg = "Service key not configured."
        Rails.logger.error msg
        raise ArgumentError, msg # Fail fast if config missing
      end

      service_key
    end

    sig { params(service_key: String, start_ord: Integer, end_ord: Integer, page_no: Integer).returns(URI::HTTP) }
    def build_api_url(service_key, start_ord, end_ord, page_no)
      uri = API_BASE_URL
      uri.query = URI.encode_www_form({
        serviceKey: service_key,
        start_ord: start_ord,
        end_ord: end_ord,
        pageNo: page_no,
        numOfRows: ROWS_PER_PAGE
      })
      uri
    end

    sig { params(items_data: T::Array[T::Hash[Symbol, T.untyped]]).returns(T::Array[Bill]) }
    def prepare_records_for_upsert(items_data)
      records = T.let([], T::Array[Bill])
      items_data.each do |item_attributes|
        next if item_attributes.empty?
        assembly_bill_id = T.cast(item_attributes[:assembly_bill_id], T.nilable(String))
        next if assembly_bill_id.blank?

        record = T.let(MODEL_CLASS.find_or_initialize_by(assembly_bill_id: assembly_bill_id), Bill)
        record.assign_attributes(item_attributes)

        records << record if record.new_record? || record.changed?
      end
      Rails.logger.debug { "Prepared #{records.count} records for upsert." }
      records
    end
  end
end
