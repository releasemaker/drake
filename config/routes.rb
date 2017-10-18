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
  resources :repos
  resources :repos, controller: 'repos', type: 'GithubRepo', as: :github_repos
  get '/gh/:owner/:repo' => 'repos#show_by_name', as: :github_repo_by_name
end
