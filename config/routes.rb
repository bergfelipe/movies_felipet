Rails.application.routes.draw do
  get 'imports/new'
  get 'imports/create'
  get 'imports/show'
    resources :imports, only: [:new, :create, :show]
    resources :categorias
    scope "(:locale)", locale: /en|pt-BR/ do
    devise_for :users

  # 🚨 Corrige logout via GET (menos seguro, mas funcional em dev)
    devise_scope :user do
      get "/users/sign_out", to: "devise/sessions#destroy"
    end
    # config/routes.rb
    get "meus_filmes", to: "filmes#meus", as: :meus_filmes

    root "filmes#index"

    resources :filmes do
      resources :comentarios, only: [:create, :destroy]
    end
  end
end