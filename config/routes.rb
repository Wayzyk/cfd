Rails.application.routes.draw do
  resources :tenants, only: [ :update ]

  resources :users, only: [ :update ]
end
