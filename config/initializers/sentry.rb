# frozen_string_literal: true

Sentry.init do |config|
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
  config.dsn = Rails.application.credentials.sentry_dsn

  # 초기 단계 서비스이므로 100% 샘플링
  config.traces_sample_rate = 1.0

  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true
end
