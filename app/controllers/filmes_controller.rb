class FilmesController < ApplicationController
  before_action :set_filme, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: %i[index show]
  before_action :autoriza_dono!, only: %i[ edit update destroy ]

  # GET /filmes
  def index
    @q = Filme.ransack(params[:q])
    @filmes = @q.result(distinct: true).includes(:categorias).order(created_at: :desc).page(params[:page]).per(6)
    @categorias = Categoria.order(:nome)
  end
  
  # app/controllers/filmes_controller.rb
def preencher_com_ia
  titulo = params[:titulo].presence || params.dig(:filme, :titulo)
  return render json: { error: "Título não informado." }, status: :unprocessable_entity if titulo.blank?

  client = OpenAI::Client.new
  prompt = <<~PROMPT
    Você é um especialista em cinema. Retorne um JSON válido com:
    {
      "sinopse": "Resumo curto do enredo.",
      "ano_lancamento": 2008,
      "duracao": 126,
      "diretor": "Nome do Diretor",
      "categorias": ["Ação", "Aventura"]
    }
    Para o filme "#{titulo}". Sempre inclua todas as chaves (pode estimar valores).
    Responda SOMENTE com JSON.
  PROMPT

  response = client.chat(
    parameters: {
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      temperature: 0.3,
      response_format: { type: "json_object" }
    }
  )

  content = response.dig("choices", 0, "message", "content")
  dados = JSON.parse(content) rescue {}

  payload = {
    sinopse:        dados["sinopse"],
    ano_lancamento: dados["ano_lancamento"],
    duracao:        dados["duracao"],
    diretor:        dados["diretor"],
    categorias:     Array(dados["categorias"]).compact
  }

  render json: payload, status: :ok
rescue => e
  render json: { error: "Erro ao buscar informações do filme: #{e.message}" }, status: :unprocessable_entity
end


  # GET /filmes/1
  def show
    @comentario = Comentario.new
    @comentarios = @filme.comentarios # já vem do mais novo pro mais antigo via default_scope
  end

  def meus
    @q = Filme.ransack(params[:q])
    @filmes = current_user.filmes.order(created_at: :desc).page(params[:page]).per(6)
    @categorias = Categoria.order(:nome)
    render :index
  end
  


  # GET /filmes/new
  def new
    @filme = current_user.filmes.build
  end

# POST /filmes
def create
  @filme = current_user.filmes.build(filme_params)
  if @filme.save
    assign_tags
    redirect_to @filme, notice: "Filme criado com sucesso."
  else
    render :new, status: :unprocessable_entity
  end
end

# PATCH/PUT /filmes/1
def update
  if @filme.update(filme_params)
    assign_tags
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
  params.require(:filme).permit(
    :titulo, :sinopse, :ano_lancamento, :duracao,
    :diretor, :imagem_url,  :poster, 
    :tag_list,                # 👈 aqui, sem array
    categoria_ids: []         # múltiplas categorias
  )
end

def assign_tags
  tag_list = @filme.tag_list.presence || params[:filme][:tag_list]
  tag_names = tag_list.to_s.split(",").map(&:strip).reject(&:blank?)
  @filme.tags = tag_names.map { |name| Tag.find_or_create_by(nome: name.downcase) }
end

  def autoriza_dono!
    return if @filme.user_id == current_user.id
    redirect_to @filme, alert: "Você não tem permissão para editar/apagar este filme."
  end
end
