Rails.application.routes.draw do
  root "home#home"
  get "/signup", to: "admin#new"
  post "/signup", to: "admin#create"
  get "/login", to: "admin#login"
  post "/login", to: "admin#create"
  resources :articles
  resources :admin
end
