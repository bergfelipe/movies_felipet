class ComentariosController < ApplicationController
    before_action :set_filme
  
    def create
      @comentario = @filme.comentarios.build(comentario_params)
      if user_signed_in?
        @comentario.user = current_user
        @comentario.nome = current_user.name.presence || current_user.email
      end
  
      if @comentario.save
        redirect_to @filme, notice: "Comentário publicado com sucesso."
      else
        @comentarios = @filme.comentarios
        flash.now[:alert] = @comentario.errors.full_messages.to_sentence
        render "filmes/show", status: :unprocessable_entity
      end
    end
  
    def destroy
      @comentario = @filme.comentarios.find(params[:id])
      if user_signed_in? && (@comentario.user_id == current_user.id || @filme.user_id == current_user.id)
        @comentario.destroy
        redirect_to @filme, notice: "Comentário removido."
      else
        redirect_to @filme, alert: "Você não tem permissão para remover este comentário."
      end
    end
  
    private
  
    def set_filme
      @filme = Filme.find(params[:filme_id])
    end
  
    def comentario_params
      params.require(:comentario).permit(:conteudo, :nome)
    end
  end
  