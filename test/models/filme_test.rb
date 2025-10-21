require "test_helper"
include ActionDispatch::TestProcess

class FilmeTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      name: "User Teste",
      email: "user_teste@example.com",
      password: "123456"
    )

    @filme = Filme.new(
      titulo: "Filme de Teste",
      sinopse: "Um filme criado apenas para testar o modelo.",
      ano_lancamento: 2024,
      duracao: 120,
      diretor: "Diretor Teste",
      user: @user,
      poster: fixture_file_upload("test/fixtures/files/test_image.jpg", "image/jpeg")
    )
  end

  test "deve ser válido com todos os atributos" do
    assert @filme.valid?, @filme.errors.full_messages.join(", ")
  end

  test "deve ser inválido sem título" do
    @filme.titulo = nil
    assert_not @filme.valid?
  end
end
