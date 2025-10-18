class CreateFilmes < ActiveRecord::Migration[7.1]
  def change
    create_table :filmes do |t|
      t.string :titulo
      t.text :sinopse
      t.integer :ano_lancamento
      t.integer :duracao
      t.string :diretor
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
