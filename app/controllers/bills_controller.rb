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
  end

  def categories
    @tab = params[:tab]
  end
end
