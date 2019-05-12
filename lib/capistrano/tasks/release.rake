# frozen_string_literal: true

namespace :deploy do
  desc "Write the current release name to RELEASE"
  after :set_current_revision, :set_current_release do
    if fetch(:release_name)
      on roles(:app) do
        within release_path do
          execute :echo, "'#{fetch(:release_name)}' > RELEASE"
        end
      end
    end
  end
end
