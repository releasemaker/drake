# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  Raven.configure do |config|
    config.excluded_exceptions += %w[SignalException]

    # Send POST data
    config.processors -= [Raven::Processor::PostData]

    # Send cookies
    # config.processors -= [Raven::Processor::Cookies]

    config.release = ApplicationRelease.current
  end
end
