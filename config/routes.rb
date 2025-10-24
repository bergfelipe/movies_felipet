Rails.application.routes.draw do
  # Rotas de importação
  resources :imports, only: [:new, :create, :show]

  # Rotas de categorias
  resources :categorias

  # Escopo de idioma
  scope "(:locale)", locale: /en|pt-BR/ do
    # Devise (autenticação)
    devise_for :users, controllers: { passwords: "passwords" }

    # 🚨 Logout via GET (funciona bem em dev)
    devise_scope :user do
      get "/users/sign_out", to: "devise/sessions#destroy"
    end

    # Página inicial
    root "filmes#index"

    # Página personalizada "Meus Filmes"
    get "meus_filmes", to: "filmes#meus", as: :meus_filmes

    # Rotas principais de filmes
    resources :filmes do
      # Endpoint IA
      collection do
        post :preencher_com_ia
      end

      # Comentários aninhados
      resources :comentarios, only: [:create, :destroy]
    end
  end
end
