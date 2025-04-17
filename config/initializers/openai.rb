OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.litellm_key
  config.uri_base = Settings.litellm.endpoint
  if Rails.env.development?
    config.log_errors = true
  end
end
