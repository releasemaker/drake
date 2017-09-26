Rails.application.routes.draw do
  root 'pages#index'

  get '/sign-in', to: 'sessions#new', as: :sign_in
  post '/sign-in', to: 'sessions#create'
  get '/auth/:provider/callback', to: 'sessions#create_oauth'
  get '/auth/failure' => 'sessions#failure_oauth', as: :oauth_failure
  get '/sign-out', :to => 'sessions#destroy', as: :sign_out
  delete '/sign-out', :to => 'sessions#destroy'

  resource :github_webhooks, only: :create, defaults: { formats: :json }

  resources :repos
  # TODO: get '/gh/*provider_uid' => 'repos#show', as: :github_repo
  resources :repos, controller: 'repos', type: 'GithubRepo', as: :github_repos
end
