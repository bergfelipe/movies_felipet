class CategoriasController < ApplicationController
  before_action :set_categoria, only: %i[ show edit update destroy ]

  # GET /categorias
  def index
    @categorias = Categoria.all
  end

  # GET /categorias/1
  def show
  end

  # GET /categorias/new
  def new
    @categoria = Categoria.new
  end

  # GET /categorias/1/edit
  def edit
  end

  # POST /categorias
  def create
    @categoria = Categoria.new(categoria_params)

    if @categoria.save
      redirect_to categorias_path, notice: "Categoria Criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categorias/1
  def update
    if @categoria.update(categoria_params)
      redirect_to @categoria, notice: "Categoria editada com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /categorias/1
  def destroy
    @categoria.destroy!
    redirect_to categorias_url, notice: "Categoria apagada com sucesso.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_categoria
      @categoria = Categoria.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def categoria_params
      params.require(:categoria).permit(:nome)
    end
end
