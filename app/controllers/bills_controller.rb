class BillsController < ApplicationController
  def index
    @bills = Bill.includes(proposals: :specific_proposer)
                 .all
                 .by_title(params[:q])
                 .by_bill_type(params[:bill_type])

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
end
