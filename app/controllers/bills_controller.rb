class BillsController < ApplicationController
  include TabParamsParser
  allow_unauthenticated_access

  def index
    filter_params = bill_filter_params
    bill_type_param = filter_params[:bill_type].presence || "법률안"
    @tabs = parsed_tabs

    @bills = Bill.includes(proposals: :specific_proposer)

    if request.params[:starred] == "true"
      ids = starred_bill_ids
      @bills = ids.any? ? @bills.where(id: ids) : @bills.none
    end

    @bills = @bills.by_title(filter_params[:q])
                   .by_bill_type(bill_type_param)

    @pagy, @bills = pagy(@bills.order(proposed_at: :desc, bill_number: :desc))

    # 페이지네이션을 위한 현재/전체 페이지 수 계산
    @current_page = @pagy.page
    @total_pages = @pagy.last
    @start_page = [ @current_page - 2, 1 ].max
    @end_page = [ @start_page + 4, @total_pages ].min
  end

  def show
    @bill = Bill.find(params[:id])
    @representative_proposer = get_representative_proposer(@bill)
  end

  def categories
    @tab = params[:tab]
  end

  private

  def get_representative_proposer(bill)
    bill.proposals.representative.first&.specific_proposer || bill.proposals.first&.specific_proposer
  end

  def bill_filter_params
    params.permit(:q, :bill_type, :starred, tab: [])
  end

  # 로컬스토리지 → 쿠키에서 ID 가져오기
  def starred_bill_ids
    JSON.parse(cookies[:starred_bill_ids] || "[]")
  rescue JSON::ParserError
    []
  end
end
