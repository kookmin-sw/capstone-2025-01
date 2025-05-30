class BillsController < ApplicationController
  include TabParamsParser
  allow_unauthenticated_access

  def index
    bill_type_param = params[:bill_type].presence || "법률안"
    @tabs = parsed_tabs

    @bills = Bill.includes(proposals: :specific_proposer)

    if request.params[:starred] == "true"
      ids = starred_bill_ids
      @bills = ids.any? ? @bills.where(id: ids) : @bills.none
    end

    @bills = @bills.by_bill_type(bill_type_param)

    keyword_blocklist = %w[김문수]
    q = params[:q]

    if q.present?
      filtered_q = q.dup
      keyword_blocklist.each do |blocked|
        filtered_q = filtered_q.gsub(blocked, "")
      end
      filtered_q = filtered_q.strip

      if filtered_q.present?
        @bills = @bills.by_title(filtered_q)
      else
        @bills = @bills.none
      end
    end
    # q가 없거나 비어있으면 @bills는 전체 목록(by_bill_type만 적용된 상태) 그대로 유지됨

    if @tabs.any?
      @bills = @bills.where(category: @tabs)
    end

    @pagy, @bills = pagy(@bills.order(proposed_at: :desc, bill_number: :desc))

    # 페이지네이션을 위한 현재/전체 페이지 수 계산
    @current_page = @pagy.page
    @total_pages = @pagy.last
    @start_page = [ @current_page - 2, 1 ].max
    @end_page = [ @start_page + 4, @total_pages ].min

    @starred_ids = starred_bill_ids
  end

  def show
    @bill = Bill.find(params[:id])
    @representative_proposer = get_representative_proposer(@bill)
    @starred_ids = starred_bill_ids
  end

  def categories
    @tab = params[:tab]
  end

  private

  def get_representative_proposer(bill)
    bill.proposals.representative.first&.specific_proposer || bill.proposals.first&.specific_proposer
  end


  # 로컬스토리지 → 쿠키에서 ID 가져오기
  def starred_bill_ids
    JSON.parse(cookies[:starred_bill_ids] || "[]")
  rescue JSON::ParserError
    []
  end
end
