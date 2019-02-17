require_relative 'revision'

if ENV['SENTRY_DSN']
  Raven.configure do |config|
    # config.excluded_exceptions = %w[
    #   ActionController::RoutingError
    #   SidekiqWorkerFailure
    #   InsufficientPermissionError
    # ]
    config.release = APPLICATION_REVISION
  end
end
