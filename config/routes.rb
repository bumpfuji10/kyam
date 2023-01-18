Rails.application.routes.draw do
  devise_for :users
  root 'static_pages#home'
  get 'issue', to: 'static_pages#issue'
  post 'articles/new', to: 'articles#create'
  resources :articles
end
