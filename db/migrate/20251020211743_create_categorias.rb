class CreateCategorias < ActiveRecord::Migration[7.1]
  def change
    create_table :categorias do |t|
      t.string :nome

      t.timestamps
    end
  end
end
