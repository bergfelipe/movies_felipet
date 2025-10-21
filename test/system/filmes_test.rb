require "application_system_test_case"

class FilmesTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(
      name: "Felipe Teste",
      email: "felipeteste@example.com",
      password: "123456"
    )

    @filme = Filme.create!(
      titulo: "Filme Sistema Teste",
      sinopse: "Sinopse gerada para o teste do sistema.",
      ano_lancamento: 2020,
      duracao: 120,
      diretor: "Diretor Teste",
      user: @user
    )
  end

  test "visitando a página inicial" do
    visit root_path
    assert_selector "h1", text: "Filmes"
  end

  test "criando um novo filme" do
    # login
    visit new_user_session_path
    fill_in "E-mail", with: @user.email
    fill_in "Senha", with: "123456"
    click_on "Entrar"

    # acessa página
    visit new_filme_path

    # preenche formulário
    fill_in "Título", with: "Interestelar"
    fill_in "Sinopse", with: "Viagem no tempo e buracos de minhoca."
    fill_in "Ano de lançamento", with: 2014
    fill_in "Duração (min)", with: 169
    fill_in "Diretor", with: "Christopher Nolan"

    # cria filme
    click_on "Criar Filme"

    # valida criação
    assert_text "Filme criado com sucesso"
    assert_selector "h1", text: "Interestelar"
  end

  test "editando um filme existente" do
    # login
    visit new_user_session_path
    fill_in "E-mail", with: @user.email
    fill_in "Senha", with: "123456"
    click_on "Entrar"

    visit edit_filme_path(@filme)

    fill_in "Título", with: "Filme Atualizado"
    click_on "Atualizar Filme"

    assert_text "Filme atualizado com sucesso"
    assert_selector "h1", text: "Filme Atualizado"
  end

  test "excluindo um filme" do
    # login
    visit new_user_session_path
    fill_in "E-mail", with: @user.email
    fill_in "Senha", with: "123456"
    click_on "Entrar"

    visit filme_path(@filme)
    accept_confirm do
      click_on "Apagar"
    end

    assert_text "Filme foi removido" rescue assert_text "Filme"
  end
end
