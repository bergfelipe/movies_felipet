class AddImagemUrlToFilmes < ActiveRecord::Migration[7.1]
  def change
    add_column :filmes, :imagem_url, :string
  end
end
