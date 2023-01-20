Rails.application.routes.draw do
  devise_for :users
  root 'static_pages#home'
  post 'articles/new', to: 'articles#create'
  resources :articles
  resources :issues
  post 'issues/new', to: 'issues#create'
end
