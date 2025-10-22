require "application_system_test_case"

class CategoriasTest < ApplicationSystemTestCase
  setup do
    @categoria = categorias(:one)
  end

  test "visiting the index" do
    visit categorias_url
    assert_selector "h1", text: "Categorias"
  end

  test "should create categoria" do
    visit categorias_url
    click_on "New categoria"

    fill_in "Nome", with: @categoria.nome
    click_on "Create Categoria"

    assert_text "Categoria was successfully created"
    click_on "Back"
  end

  test "should update Categoria" do
    visit categoria_url(@categoria)
    click_on "Edit this categoria", match: :first

    fill_in "Nome", with: @categoria.nome
    click_on "Update Categoria"

    assert_text "Categoria was successfully updated"
    click_on "Back"
  end

  test "should destroy Categoria" do
    visit categoria_url(@categoria)
    click_on "Destroy this categoria", match: :first

    assert_text "Categoria was successfully destroyed"
  end
end
