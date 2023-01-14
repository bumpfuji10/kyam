Rails.application.routes.draw do
  root "home#home"
  resources :articles
end
