class ImportMailer < ApplicationMailer
  default from: "notificacoes@movies.com"

  def resultado
    @user    = params[:user]
    @sucesso = params[:sucesso]
    @erros   = params[:erros]

    # Renderiza o mesmo template de e-mail (HTML)
    html_content = render_to_string(template: "import_mailer/resultado")

    # Envia via API HTTPS (funciona no Render Free)
    SendgridApiMailer.send_email(
      to: @user.email,
      subject: "Importação de filmes concluída!",
      content: html_content
    )
  rescue => e
    Rails.logger.error("❌ Falha ao enviar e-mail de importação: #{e.message}")
  end
end
