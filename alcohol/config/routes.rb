Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  root 'static_pages#top'
  get  "/top",    to: "static_pages#top"
  get  "/signup",  to: "users#new"
  get    "/login",   to: "sessions#new"
  post   "/login",   to: "sessions#create"
  delete "/logout",  to: "sessions#destroy"
  get    "/record",   to: "records#new"
  resources :users
  resources :records do
    collection do
      get 'edit_by_day', to: 'records#edit_by_day'
      patch 'update_record', to: 'records#update_record', as: 'update_record'
      delete 'destroy_record', to: 'records#destroy_record', as: 'destroy_record'
    end
  end
  resources :limits
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
end
