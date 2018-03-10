if ENV['SENTRY_DSN']
  Raven.configure do |config|
    # config.dsn = Rails.configuration.sentry.dsn
    # config.environments = %w(production staging development)
    # config.current_environment = Rails.env
    # config.excluded_exceptions = %w(
    #   ActionController::RoutingError
    #   SidekiqWorkerFailure
    #   InsufficientPermissionError
    # )

    begin
      File.open(Rails.root.join('REVISION')) do |revision_file|
        if Rails.env.production?
          config.release = revision_file.read.strip.split("\n").first
        else
          config.release = revision_file.read.strip.split("\n").second
        end
      end
    rescue Errno::ENOENT
    end
  end
end
