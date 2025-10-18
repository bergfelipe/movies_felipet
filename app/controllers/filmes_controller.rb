class FilmesController < ApplicationController
  before_action :set_filme, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: %i[index show]
  before_action :autoriza_dono!, only: %i[ edit update destroy ]

  # GET /filmes
  def index
    @filmes = Filme.includes(:user).order(created_at: :desc).page(params[:page]).per(6)
  end

  # GET /filmes/1
  def show
    @comentario = Comentario.new
    @comentarios = @filme.comentarios # já vem do mais novo pro mais antigo via default_scope
  end

  # GET /filmes/new
  def new
    @filme = current_user.filmes.build
  end

  # POST /filmes
  def create
    @filme = current_user.filmes.build(filme_params)
    if @filme.save
      redirect_to @filme, notice: "Filme criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /filmes/1
  def update
    if @filme.update(filme_params)
      redirect_to @filme, notice: "Filme atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /filmes/1
  def destroy
    @filme.destroy
    redirect_to filmes_url, notice: "Filme apagado com sucesso."
  end

  private

  def set_filme
    @filme = Filme.find(params[:id])
  end

  def filme_params
    params.require(:filme).permit(:titulo, :sinopse, :ano_lancamento, :duracao, :diretor)
  end

  def autoriza_dono!
    return if @filme.user_id == current_user.id
    redirect_to @filme, alert: "Você não tem permissão para editar/apagar este filme."
  end
end
