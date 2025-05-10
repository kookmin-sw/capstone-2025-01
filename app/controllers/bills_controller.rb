class BillsController < ApplicationController
  allow_unauthenticated_access

  def index
    params = bill_filter_params
    # params[:bill_type]가 nil인 경우, 기본값으로 "법률안"을 사용
    bill_type_param = params[:bill_type].presence || "법률안"

    @bills = Bill.includes(proposals: :specific_proposer)
                 .all
                 .by_title(params[:q])
                 .by_bill_type(bill_type_param)

    @pagy, @bills = pagy(@bills.order(proposed_at: :desc, bill_number: :desc))
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
    # 대표발의 존재 시 대표발의자 중 첫 번째
    representative_proposer = bill.proposals.representative.first&.specific_proposer
    # 대표발의가 없을 경우, 첫 번째 발의자
    representative_proposer ||= bill.proposals.first&.specific_proposer
    representative_proposer
  end

  def bill_filter_params
    params.permit(:q, :bill_type)
  end
end
