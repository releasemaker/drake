Rails.application.routes.draw do
  root 'pages#index'

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure' => 'sessions#failure'
  delete '/sign_out', :to => 'sessions#destroy'

  resource :github_webhooks, only: :create, defaults: { formats: :json }

  resources :repos
end
