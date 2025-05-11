# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  configure do |config|
    config.path_prefix = "/oauth"
    config.logger = Rails.logger if Rails.env.development?
  end

  provider :naver, Rails.application.credentials.dig(:oauth, :naver, :client_id), Rails.application.credentials.dig(:oauth, :naver, :client_secret)
end
