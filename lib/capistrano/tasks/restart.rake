# frozen_string_literal: true

namespace :deploy do
  desc "Restart the application"
  after :published, :restart do
    on roles(:app) do
      execute "/usr/bin/touch", "#{shared_path}/restart.txt"
    end
  end
end
