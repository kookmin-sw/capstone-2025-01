class BillsController < ApplicationController
  def index
    @bills = Bill.includes(proposals: :specific_proposer)
                 .all
                 .by_title(params[:q])
                 .by_bill_type(params[:bill_type])

    @pagy, @bills = pagy(@bills.order(created_at: :desc))
  end

  def show
    @bill = Bill.find(params[:id])

    # 법안 제안자(국회/정부)
    @proposer_type = @bill.proposals.first&.specific_proposer_type if @bill.proposals.any?
    # 정부입법 제안자(부처)
    @government_sponsor = @bill.proposals.find_by(specific_proposer_type: "GovernmentBillSponsor")&.specific_proposer
  end

  def categories
    @tab = params[:tab]
  end
end
