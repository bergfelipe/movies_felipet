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
  
  def preencher_com_ia
    titulo = params[:titulo].presence || params.dig(:filme, :titulo)
    return render json: { error: "Título não informado." }, status: :unprocessable_entity if titulo.blank?

    if OpenAI.configuration.access_token.to_s.strip.blank?
      return render json: {
        error: "Chave da OpenRouter não configurada. Defina OPENROUTER_API_KEY no ambiente."
      }, status: :unprocessable_entity
    end

    client = OpenAI::Client.new
    model = ENV.fetch("OPENROUTER_MODEL", "openai/gpt-4o-mini")
    provider_options = {
      data_collection: ENV.fetch("OPENROUTER_DATA_COLLECTION", "deny")
    }
    provider_options[:zdr] = true if ActiveModel::Type::Boolean.new.cast(ENV.fetch("OPENROUTER_ZDR", "true"))

    prompt = <<~PROMPT
      Você é um especialista em cinema.
      Responda SOMENTE com um JSON válido no formato:
  
      {
        "conhecido": true|false,
        "titulo_canonico": "Título oficial do filme",
        "sinopse": "Resumo curto e factual do enredo.",
        "ano_lancamento": 2008,
        "duracao": 126,
        "diretor": "Nome do Diretor",
        "categorias": ["Ação", "Aventura"]
      }
  
      Regras IMPORTANTES:
      - Se o título "#{titulo}" NÃO corresponder com alta confiança a um filme real (ex.: presente em IMDb/Wikipedia/TMDb), retorne:
        { "conhecido": false }
        e NADA MAIS.
      - NUNCA invente. Se houver dúvida, retorne {"conhecido": false}.
      - Preencha todos os campos apenas se "conhecido" for true.
      - "duracao" deve ser minutos (inteiro, entre 45 e 240).
      - "ano_lancamento" entre 1900 e #{Time.current.year + 1}.
      - Categorias em PT-BR (ex.: "Ação", "Drama", "Comédia", "Suspense", "Terror", "Romance", "Ficção", "Aventura", "Documentário").
    PROMPT

    response = client.chat(
      parameters: {
        model: model,
        temperature: 0.1,
        provider: provider_options,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: "Você responde apenas JSON válido." },
          { role: "user", content: prompt }
        ]
      }
    )
    content = response.dig("choices", 0, "message", "content").to_s
    dados = JSON.parse(content)

    # --- Guarda de não encontrado / baixa confiança ---
    if !dados.is_a?(Hash) || dados["conhecido"] != true
      return render json: {
        error: "Filme não encontrado. Informe o título completo ou mais detalhes (ex.: ano ou diretor)."
      }, status: :unprocessable_entity
    end
  
    # --- Sane checks adicionais contra alucinação ---
    ano = dados["ano_lancamento"].to_i
    dur = dados["duracao"].to_i
    diretor = (dados["diretor"] || "").to_s.strip
    sinopse = (dados["sinopse"] || "").to_s.strip
  
    ano_ok = ano.between?(1900, Time.current.year + 1)
    dur_ok = dur.between?(45, 240)
    diretor_ok = diretor.length >= 3 && diretor.match?(/[A-Za-zÀ-ÿ]/)
    sinopse_ok = sinopse.length >= 20 && !sinopse.match?(/desconhecido|n.?o sei|indispon[ií]vel/i)
  
    unless ano_ok && dur_ok && diretor_ok && sinopse_ok
      return render json: {
        error: "Não consegui confirmar este filme. Refine o título (ex.: ano/diretor) e tente novamente."
      }, status: :unprocessable_entity
    end
  
    categorias = case dados["categorias"]
                 when Array
                   dados["categorias"]
                 when String
                   dados["categorias"].split(",")
                 else
                   []
                 end

    payload = {
      sinopse:        sinopse,
      ano_lancamento: ano,
      duracao:        dur,
      diretor:        diretor,
      categorias:     categorias.map { |c| c.to_s.strip }.reject(&:blank?)
    }

    render json: payload, status: :ok
  rescue JSON::ParserError
    render json: { error: "A IA retornou conteúdo inválido. Tente novamente." }, status: :unprocessable_entity
  rescue Faraday::UnauthorizedError
    render json: { error: "Falha de autenticação com a OpenRouter. Verifique OPENROUTER_API_KEY." }, status: :unprocessable_entity
  rescue Faraday::TooManyRequestsError
    render json: { error: "Limite/cota da OpenRouter atingido. Verifique billing e quota do projeto." }, status: :unprocessable_entity
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
    @filme.destroy!
    redirect_to filmes_url, notice: "Filme apagado com sucesso."
  rescue Aws::S3::Errors::ServiceError => e
    Rails.logger.error("Falha ao apagar arquivo no S3 para Filme##{@filme.id}: #{e.class} - #{e.message}")

    # Se o objeto no S3 estiver inacessível, destacamos o attachment para
    # permitir remover o registro sem quebrar a UX com erro 500.
    @filme.poster.detach if @filme.poster.attached?
    @filme.destroy!

    redirect_to filmes_url, alert: "Filme removido, mas não foi possível apagar a imagem antiga no S3."
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
