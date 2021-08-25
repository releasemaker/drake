# frozen_string_literal: true

namespace :deploy do
  before :compile_assets, :yarn_install do
    on roles(:web) do
      within release_path do
        execute :yarn, "install"
      end
    end
  end
end
