# frozen_string_literal: true

RSpec.configure do |config|
  # We don't use RSpecs transaction fixtures because we use DatabaseCleaner instead.
  # http://weilu.github.io/blog/2012/11/10/conditionally-switching-off-transactional-fixtures/
  config.use_transactional_fixtures = false

  tables_not_to_truncate = %w[
    schema_migrations
    ar_internal_metadata
  ]

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation, except: tables_not_to_truncate
    Rails.application.load_seed
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = if example.metadata[:requires_transaction]
      [:truncation, {except: tables_not_to_truncate}]
    else
      :transaction
    end
    DatabaseCleaner.start
  end

  config.after(:each) do |example|
    DatabaseCleaner.clean
    Rails.application.load_seed if example.metadata[:requires_transaction]
  end
end
