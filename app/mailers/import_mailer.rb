class ImportMailer < ApplicationMailer
  default from: "notificacoes@movies.com"

  def resultado
    @user = params[:user]
    @sucesso = params[:sucesso]
    @erros = params[:erros]

    mail(to: @user.email, subject: "Importação de filmes concluída!")
  end
end
