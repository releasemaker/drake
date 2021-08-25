# frozen_string_literal: true

OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :github,
    Rails.configuration.x.github.oauth_client_id,
    Rails.configuration.x.github.oauth_secret,
    scope: "user:email,repo",
  )
end
