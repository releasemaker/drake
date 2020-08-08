source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'

# Use Puma as the app server
gem 'puma', '~> 3.7'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Distributed mutex in Ruby using Redis. Supports both blocking and non-blocking semantics.
gem 'redis-mutex'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
group :development do
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'

  # For modern SSH key support
  gem 'rbnacl', '>= 3.2', '< 5.0', require: false
  gem 'ed25519', require: false
  gem 'bcrypt_pbkdf', '~> 1.0', require: false
end

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Authenticate webhooks
gem 'github_webhook'

# A useful console
gem 'pry-rails'

# Exception reporting to Sentry
gem "sentry-raven"

# Use the github API
gem "github_api"

# Version number manipulation
gem "versionomy"

# Style
gem 'foundation-rails', "~> 6.0"
gem 'foundation_rails_helper', '~> 3.0.0rc1'

# Add jQuery is used by Foundation's JS
gem 'jquery-rails'

# Authentication
gem 'sorcery'
gem 'omniauth'
gem 'omniauth-github'

# Templates
gem 'slim'

# Authorization
gem 'cancancan'

# Pagination
gem 'kaminari'

# Redis driver used by rails cache
gem 'hiredis'

# Icons
gem "font-awesome-rails"

# React components kicked off by Rails
gem 'react-rails'

# Performance monitoring
gem "skylight"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'dotenv-rails'

  gem 'pry-byebug'
  # gem 'pry-doc' # Removed until support for Ruby 2.7.0 is added.
  # gem 'pry-remote'
  gem 'pry-rescue'
  # gem 'pry-stack_explorer'
  gem 'pry-clipboard'

  # Documentation!
  gem 'yard'
  gem 'yard-activerecord'

  # Testing. These are also needed in development so that Rails generators are available.
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_bot_rails'
  gem 'rspec_junit_formatter'
  gem 'capybara'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Access an IRB console on exception pages
  gem 'better_errors'
  gem 'binding_of_caller'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'

  gem 'guard', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-bundler', require: false
  gem 'guard-pow', require: false
  gem 'guard-rspec', require: false
  gem 'rubocop-rspec', require: false
  install_if -> { RUBY_PLATFORM =~ /darwin/ } do
    gem 'terminal-notifier-guard', require: false
    gem 'terminal-notifier', require: false
    gem 'launchy', require: false
  end
end

group :test do
  gem 'rspec-html-matchers'
  gem 'rspec-collection_matchers'
  gem 'rspec-mocks'
  gem 'rspec-json_matchers'
  gem 'timecop'
  gem 'database_cleaner'
  gem 'webmock'
  gem 'vcr'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
