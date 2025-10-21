require "test_helper"

class FilmesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Felipe Teste",
      email: "felipeteste@example.com",
      password: "123456"
    )
  
    sign_in_as(@user)
  
    @filme = Filme.create!(
      titulo: "Filme Teste",
      sinopse: "Uma sinopse para teste.",
      ano_lancamento: 2020,
      duracao: 120,
      diretor: "Diretor Teste",
      user: @user,
      poster: fixture_file_upload("test/fixtures/files/test_image.jpg", "image/jpeg")
    )
  end
  

  test "deve acessar a lista de filmes" do
    get filmes_url
    assert_response :success
  end

  test "deve acessar a tela de novo filme" do
    get new_filme_url
    assert_response :success
  end

  test "deve criar um novo filme" do
    assert_difference("Filme.count") do
      post filmes_url, params: {
        filme: {
          titulo: "Novo Filme Teste",
          sinopse: "Outro teste de criação.",
          ano_lancamento: 2024,
          duracao: 130,
          diretor: "Outro Diretor"
        }
      }
    end
    assert_redirected_to filme_url(Filme.last)
  end

  test "deve mostrar um filme" do
    get filme_url(@filme)
    assert_response :success
  end

  test "deve acessar a tela de edição" do
    get edit_filme_url(@filme)
    assert_response :success
  end

  test "deve atualizar um filme" do
    patch filme_url(@filme), params: {
      filme: { titulo: "Filme Atualizado" }
    }
    assert_redirected_to filme_url(@filme)
    @filme.reload
    assert_equal "Filme Atualizado", @filme.titulo
  end

  test "deve excluir um filme" do
    assert_difference("Filme.count", -1) do
      delete filme_url(@filme)
    end
    assert_redirected_to filmes_url
  end
end
