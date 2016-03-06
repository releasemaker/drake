Rails.application.routes.draw do
  root 'pages#index'

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure' => 'sessions#failure'
  delete '/sign_out', :to => 'sessions#destroy'

  resource :github_webhooks, only: :create, defaults: { formats: :json }

  resources :repos
  # TODO: get '/gh/*provider_uid' => 'repos#show', as: :github_repo
  resources :repos, controller: 'repos', type: 'GithubRepo', as: :github_repos
end
