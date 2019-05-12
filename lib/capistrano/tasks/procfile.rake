# frozen_string_literal: true

namespace :deploy do
  desc "Prepare the Procfile for the destination node"
  before :updating, :prepare_procfile do
    on roles(:app) do |host|
      worker_formation = host.properties.worker.fetch(:formation)
      within release_path do
        if worker_formation
          # worker_formation variable must be set on each 'worker' server.
          # See http://ddollar.github.io/foreman/#DEFAULT-OPTIONS for the format
          execute :echo, "formation: #{worker_formation}", '> .foreman'
        else
          # We don't want procfiles left lying around on web servers.
          execute :rm, 'Procfile || true'
        end
      end
    end
  end
end
