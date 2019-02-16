Rails.application.routes.draw do
  root 'pages#index'

  get '/sign-in', to: 'sessions#new', as: :sign_in
  post '/sign-in', to: 'sessions#create'
  get '/auth/:provider/callback', to: 'sessions#create_oauth'
  get '/auth/failure' => 'sessions#failure_oauth', as: :oauth_failure
  get '/sign-out', :to => 'sessions#destroy', as: :sign_out
  delete '/sign-out', :to => 'sessions#destroy'

  resource :github_webhooks, only: :create, defaults: { formats: :json }

  get :dashboard, to: redirect('/repos')

  namespace :api, default: { format: 'json' } do
    get 'availableRepos', to: 'available_repos#index'
    get 'repos', to: 'repos#index'
    post 'repos/:repo_type/:owner_name/:repo_name', to: 'repos#create', constraints: { type: /gh/ }
    get 'repos/:repo_type/:owner_name/:repo_name', to: 'repos#show', constraints: { type: /gh/ }
    patch 'repos/:repo_type/:owner_name/:repo_name', to: 'repos#update', constraints: { type: /gh/ }
    get '*url' => 'error#not_found', as: :not_found
  end

  get '*url' => 'pages#app', as: :app
end
