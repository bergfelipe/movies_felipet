class ChangeComentariosUserIdNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :comentarios, :user_id, true
  end
end
