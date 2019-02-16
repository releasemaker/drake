namespace :deploy do
  desc "Write the current release name to RELEASE"
  task :set_current_release do
    return unless fetch(:release_name)

    on roles(:app) do
      execute :echo, "'#{fetch(:release_name)}' > #{fetch(:release_path)}/RELEASE"
    end
  end
  after "deploy:set_current_revision", "deploy:set_current_release"
end
