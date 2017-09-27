class SidekiqInitializer
  include Singleton
  extend SingleForwardable
  def_delegators :instance, :perform!

  def perform!
    configure_client_redis!
    configure_server_redis!
    configure_server_database!
  end

  private

  def client_redis_pool_size
    50
  end

  def server_redis_pool_size
    50
  end

  def configure_client_redis!
    Sidekiq.configure_client do |config|
      configure_redis_for_environment(config, client_redis_pool_size)
    end
  end

  def configure_server_redis!
    Sidekiq.configure_server do |config|
      configure_redis_for_environment(config, client_redis_pool_size)
    end
  end

  # Set the pool size to the max of the number of threads we'll be running.
  def configure_server_database!
    Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        database_config = config_for(:database)
        database_config.pool = [
          config.options[:database_pool_size],
          config.options[:concurrency] + 1,
          database_config.pool,
        ].compact.max
        Rails.logger.info "Setting database pool size to #{database_config.pool} for Sidekiq server"

        ActiveRecord::Base.connection_pool.disconnect! rescue ActiveRecord::ConnectionNotEstablished
        ActiveRecord::Base.establish_connection(database_config)
        ActiveRecord::Base.connection_pool.connections.first.verify!
      end
    end
  end

  def configure_redis_for_environment(config, pool_size)
    if Rails.env.development?
      config.redis = { namespace: 'goldi-development' }
    elsif Rails.env.test?
      # MockRedis will be used, so no configuration necessary.
    else
      config.redis = { pool: pool_size }
    end
  end
end

SidekiqInitializer.perform!
