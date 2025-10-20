class CreateJoinTableFilmesCategorias < ActiveRecord::Migration[7.1]
  def change
    create_join_table :filmes, :categorias do |t|
      # t.index [:filme_id, :categoria_id]
      # t.index [:categoria_id, :filme_id]
    end
  end
end
