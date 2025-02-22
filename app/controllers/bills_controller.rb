class BillsController < ApplicationController
  def index
    @pagy, @bills = pagy(Bill.all)
  end

  def show
    @bill = Bill.find(params[:id])
    @bill_events = @bill.bill_events.order(:event_date)
  end
end
