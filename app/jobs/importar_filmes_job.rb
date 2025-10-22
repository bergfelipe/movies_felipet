require "csv"

class ImportarFilmesJob < ApplicationJob
  queue_as :default

  def perform(user_id, file_path)
    user = User.find(user_id)
    sucesso = 0
    erros = []

    CSV.foreach(file_path, headers: true, col_sep: ",") do |linha|
      filme = user.filmes.new(
        titulo: linha["titulo"],
        sinopse: linha["sinopse"],
        ano_lancamento: linha["ano_lancamento"],
        duracao: linha["duracao"],
        diretor: linha["diretor"],
        imagem_url: linha["imagem_url"]
      )

      if filme.save
        sucesso += 1
      else
        erros << { titulo: linha["titulo"], mensagens: filme.errors.full_messages }
      end
    end

    # Simples feedback no log (depois colocamos email)
    Rails.logger.info "Importação concluída: #{sucesso} filmes salvos, #{erros.size} erros."
    ImportMailer.with(user: user, sucesso: sucesso, erros: erros).resultado.deliver_now
  end
end
