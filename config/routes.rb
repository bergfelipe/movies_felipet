# config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  root "filmes#index"

  resources :filmes do
    resources :comentarios, only: [:create, :destroy]
  end
end
