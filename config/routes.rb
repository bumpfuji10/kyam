Rails.application.routes.draw do
  devise_for :users
  get 'articles/new', to: 'articles#new'
  get 'articles', to: 'articles#index'
  root 'static_pages#home'
end
