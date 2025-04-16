# frozen_string_literal: true
# typed: true

require "net/http"
require "uri"

require_relative "../../lib/api_client"
require_relative "../../lib/data_go_kr/bill_jsiction_comite_process_list_parser"
require_relative "../../lib/data_go_kr/bill_recent_moor_list_parser"
require_relative "../concerns/bulk_upsertable"

module PeriodicJobs
  class BulkUpdateBillCommitteeInfoPeriodicJob < ApplicationJob
    extend T::Sig
    include ApiClient
    include BulkUpsertable

    queue_as :default

    # 처리 의안 목록 정보 API
    BILL_JSICTION_COMITE_PROCESS_API_URL = T.let(URI::HTTP.build(host: "apis.data.go.kr", path: "/9710000/BillInfoService2/getJsictionComiteProcessList"), URI::HTTP)
    # 계류 의안 목록 정보 API
    BILL_RECENT_MOOR_API_URL = T.let(URI::HTTP.build(host: "apis.data.go.kr", path: "/9710000/BillInfoService2/getRecentMoorList"), URI::HTTP)

    ROWS_PER_PAGE = 1000
    MODEL_CLASS = T.let(Bill, T.class_of(ActiveRecord::Base))

    # 의회 대수 기본값
    DEFAULT_START_ORD = 22

    DEFAULT_SLEEP_SECONDS = 10.0

    class ApiError < StandardError; end
    class AuthenticationError < ApiError; end
    class TransientError < ApiError; end


    sig { params(start_ord: T.nilable(Integer), end_ord: T.nilable(Integer), sleep_seconds: T.nilable(Float)).void }
    def perform(start_ord = nil, end_ord = nil, sleep_seconds = nil)
      service_key = get_service_key()
      start_ord_setting = T.let(Settings.bills&.start_ord, T.nilable(Integer))
      sleep_setting = T.let(Settings.bills&.api_sleep_seconds, T.nilable(Float))

      start_ord = start_ord || start_ord_setting || DEFAULT_START_ORD
      sleep_seconds = sleep_seconds || sleep_setting || DEFAULT_SLEEP_SECONDS

      # Process each API
      Rails.logger.info "Starting to process bill committee information..."

      process_jsiction_comite_process_list(service_key, start_ord, sleep_seconds)
      process_recent_moor_list(service_key, start_ord, sleep_seconds)

      Rails.logger.info "Finished updating #{T.must(MODEL_CLASS.name).pluralize} committee information."
    end

    private

    # 처리 의안 API 조회
    sig { params(service_key: String, start_ord: Integer, sleep_seconds: Float).void }
    def process_jsiction_comite_process_list(service_key, start_ord, sleep_seconds)
      Rails.logger.info "Processing bills from JsictionComiteProcessList API..."
      parser = DataGoKr::BillJsictionComiteProcessListParser.new

      fetch_and_process_api_data(
        BILL_JSICTION_COMITE_PROCESS_API_URL,
        service_key,
        start_ord,
        sleep_seconds,
        parser,
        [ :committee_name ]
      )
    end

    # 계류 의안 API 조회
    sig { params(service_key: String, start_ord: Integer, sleep_seconds: Float).void }
    def process_recent_moor_list(service_key, start_ord, sleep_seconds)
      Rails.logger.info "Processing bills from RecentMoorList API..."
      parser = DataGoKr::BillRecentMoorListParser.new

      fetch_and_process_api_data(
        BILL_RECENT_MOOR_API_URL,
        service_key,
        start_ord,
        sleep_seconds,
        parser,
        [ :committee_name ]
      )
    end


    sig { params(
      api_url: URI::HTTP,
      service_key: String,
      start_ord: Integer,
      sleep_seconds: Float,
      parser: DataGoKr::ListApiParser,
      update_columns: T::Array[Symbol]
    ).void }
    def fetch_and_process_api_data(api_url, service_key, start_ord, sleep_seconds, parser, update_columns)
      page_no = 1
      total_pages = 1
      has_pagination = T.let(true, T::Boolean)

      loop do
        log_message = "Processing #{T.must(MODEL_CLASS.name).pluralize}..."
        log_message = "Processing page #{page_no} of #{T.must(MODEL_CLASS.name).pluralize}..." if has_pagination && page_no > 1
        Rails.logger.info(log_message)

        url = build_api_url(api_url, service_key, start_ord, page_no)

        begin
          response_body = ApiClient.fetch_with_retry(url)
          parse_result = parser.parse(response_body)
          items_data = T.let(parse_result.items, T::Array[T::Hash[Symbol, T.untyped]])
          Rails.logger.debug { "Parsed #{items_data.count} items." }

          records_to_upsert = prepare_records_for_upsert(items_data, update_columns)
          bulk_upsert(
            records_to_upsert,
            MODEL_CLASS,
            conflict_target: [ :assembly_bill_id ],
            update_columns: update_columns,
            silence: true,
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

        if sleep_seconds > 0 && page_no <= total_pages
          Rails.logger.debug { "Sleeping for #{sleep_seconds} seconds before next API call." }
          sleep(sleep_seconds)
        end
      end
    end

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

    sig { params(uri: URI::HTTP, service_key: String, start_ord: Integer, page_no: Integer).returns(URI::HTTP) }
    def build_api_url(uri, service_key, start_ord, page_no)
      uri.query = URI.encode_www_form({
        serviceKey: service_key,
        start_age_cd: start_ord,
        pageNo: page_no,
        numOfRows: ROWS_PER_PAGE
      })
      uri
    end

    sig { params(
      items_data: T::Array[T::Hash[Symbol, T.untyped]],
      only_columns: T.nilable(T::Array[Symbol]) # 업데이트할 컬럼들을 포함해야 함
    ).returns(T::Array[Bill]) }
    def prepare_records_for_upsert(items_data, only_columns = nil)
      # 1. 가져온 데이터에서 assembly_bill_id 목록 추출
      assembly_bill_ids = items_data.map { |item| item[:assembly_bill_id] }.compact.uniq
      return [] if assembly_bill_ids.empty?

      # 2. 이 ID들과 일치하는 기존 레코드를 데이터베이스에서 찾기
      existing_records = MODEL_CLASS.where(assembly_bill_id: assembly_bill_ids).index_by(&:assembly_bill_id)
      return [] if existing_records.empty?

      records_to_update = T.let([], T::Array[Bill])
      model_attribute_names = MODEL_CLASS.attribute_names.map(&:to_sym)

      items_data.each do |item_attributes|
        assembly_bill_id = T.cast(item_attributes[:assembly_bill_id], T.nilable(String))
        next if assembly_bill_id.blank?

        # 3. 해당하는 기존 레코드 가져오기
        record = existing_records[assembly_bill_id]
        next unless record # DB에 레코드가 없으면 건너뛰기

        # 4. 모델에 존재하고 only_columns에 포함된 속성만 필터링
        #    (assembly_bill_id는 레코드 조회로 이미 처리됨)
        attributes_to_assign = item_attributes.select do |key, _|
          model_attribute_names.include?(key) &&
            (only_columns.nil? || only_columns.include?(key)) &&
            key != :assembly_bill_id # PK를 다시 할당하지 않음
        end

        # 5. 속성 할당 및 레코드가 실제로 변경되었는지 확인
        record.assign_attributes(attributes_to_assign)
        records_to_update << record if record.changed? # 변경된 레코드만 포함
      end

      Rails.logger.debug { "Prepared #{records_to_update.count} existing records for update." }
      records_to_update # 업데이트가 필요한 기존 레코드만 반환
    end
  end
end
