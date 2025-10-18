class CreateComentarios < ActiveRecord::Migration[7.1]
  def change
    create_table :comentarios do |t|
      t.text :conteudo
      t.string :nome
      t.references :user, null: false, foreign_key: true
      t.references :filme, null: false, foreign_key: true

      t.timestamps
    end
  end
end
