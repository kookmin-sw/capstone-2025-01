class HomeController < ApplicationController
    allow_unauthenticated_access  # 👈 인증 없이 접근 허용!

    def index
      @hot_bills = Bill.order(proposed_at: :desc).limit(6)
    end
end
