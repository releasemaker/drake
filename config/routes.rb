Rails.application.routes.draw do
  root 'pages#index'

  get '/sign-in', to: 'sessions#new', as: :sign_in
  post '/sign-in', to: 'sessions#create'

  # When OAuth fails
  get '/auth/failure' => 'sessions#failure_oauth', as: :oauth_failure
  # No longer provided by Omniauth, since starting the Request phase requires a POST
  get '/auth/:provider', to: redirect('/dashboard')
  # Start the OAuth callback phase
  get '/auth/:provider/callback', to: 'sessions#create_oauth'

  get '/sign-out', :to => 'sessions#destroy', as: :sign_out
  delete '/sign-out', :to => 'sessions#destroy'

  resource :github_webhooks, only: :create, defaults: { formats: :json }

  get :dashboard, to: redirect('/repos')

  namespace :api, default: { format: 'json' } do
    get 'gimme/error', to: 'error#server_error'
    get 'gimme/bad-json', to: 'error#bad_json'
    get 'availableRepos', to: 'available_repos#index'
    get 'repos', to: 'repos#index'
    post 'repos/:repo_type/:owner_name/:repo_name', to: 'repos#create', constraints: { type: /gh/, repo_name: /[0-z\.\-]+/ }
    get 'repos/:repo_type/:owner_name/:repo_name', to: 'repos#show', constraints: { type: /gh/, repo_name: /[0-z\.\-]+/ }
    patch 'repos/:repo_type/:owner_name/:repo_name', to: 'repos#update', constraints: { type: /gh/, repo_name: /[0-z\.\-]+/ }
    get '*url' => 'error#not_found', as: :not_found
  end

  get '*url' => 'pages#app', as: :app
end
