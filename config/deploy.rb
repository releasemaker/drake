# config valid for current version and patch releases of Capistrano
lock "~> 3.10"

set :application, "releasemaker"

if ENV['CI']
  set :repo_url, ENV['CIRCLE_REPOSITORY_URL']
  set :branch, ENV['CIRCLE_SHA1']
else
  set :repo_url, 'git@github.com:RobinDaugherty/release_maker-ruby.git'
end

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/releasemaker_#{fetch :stage}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
set :ssh_options, verify_host_key: :secure

set :rbenv_type, :system
set :rbenv_ruby, File.read('.ruby-version').strip
# set :rbenv_path, '/usr/local/rbenv'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w(rake gem bundle ruby rails)
set :rbenv_roles, :all # default value

# set :bundle_jobs, 8 # Speed up bundle install by running this many gem installs at a time.
# set :bundle_binstubs, nil # Rails has its own binstubs.
# set :bundle_path, -> { "vendor/bundle" } # Use the correct default that bundler itself uses.

set :run_migrations, true

namespace :deploy do
  after :published, :restart_rails do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      execute "/usr/bin/touch '#{shared_path}/restart.txt'"
    end
  end
end
