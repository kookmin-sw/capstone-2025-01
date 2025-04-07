class BillsController < ApplicationController
  def index
    @bills = Bill.all
                 .by_title(params[:q])
                 .by_department(params[:department_id])
                 .by_domain(params[:domain])
                 .by_bill_type(params[:bill_type])

    @pagy, @bills = pagy(@bills.order(created_at: :desc))
  end

  def show
    @bill = Bill.find(params[:id])
    @bill_events = @bill.bill_events.order(:event_date)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def categories
    @tab = params[:tab]
  end
end
