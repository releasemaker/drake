namespace :deploy do
  desc "Write the current release name to RELEASE"
  task :set_current_release do
    return unless fetch(:release_name)

    on roles(:app) do
      within_release_path do
        execute :echo, "'#{fetch(:release_name)}' > RELEASE"
      end
    end
  end
  after "deploy:set_current_revision", "deploy:set_current_release"
end
