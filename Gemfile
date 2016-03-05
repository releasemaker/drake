source 'https://rubygems.org'

ruby '2.4.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'

# Use Puma as the app server
gem 'puma', '~> 3.7'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Authenticate webhooks
gem 'github_webhook', github: 'RandomServices/github_webhook'

# A useful console
gem 'pry-rails'

# Performance monitoring and exception reporting
gem 'newrelic_rpm'

# Exception reporting to Sentry
gem "sentry-raven"

# Use the github API
gem "github_api"

# Version number manipulation
gem "versionomy"

# Style
gem 'foundation-rails', "~> 6.0"
gem 'foundation_rails_helper'

# Authentication
gem 'sorcery'
gem 'omniauth'
gem 'omniauth-github'

# Templates
gem 'slim'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'dotenv-rails'

  gem 'pry-byebug'
  gem 'pry-doc'
  # gem 'pry-remote'
  gem 'pry-rescue'
  # gem 'pry-stack_explorer'
  gem 'pry-clipboard'

  # Testing. These are also needed in development so that Rails generators are available.
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'dotenv-rails'
  gem 'rspec_junit_formatter'
  gem 'capybara'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Access an IRB console on exception pages
  gem 'better_errors'
  gem 'binding_of_caller'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'guard', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-bundler', require: false
  gem 'guard-pow', require: false
  gem 'guard-rspec', require: false
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
