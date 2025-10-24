class PasswordsController < Devise::PasswordsController
  def create
    self.resource = resource_class.find_by(email: resource_params[:email])

    if resource
      # Cria um token de redefinição de senha
      token = resource.send(:set_reset_password_token)
      url = edit_password_url(resource, reset_password_token: token, locale: I18n.locale)

      # Monta o HTML do e-mail
      html = <<-HTML
        <p>Olá #{resource.name || 'usuário'},</p>
        <p>Você solicitou a redefinição da sua senha. Para continuar, clique no link abaixo:</p>
        <p><a href="#{url}">Redefinir minha senha</a></p>
        <p>Se você não fez essa solicitação, ignore este e-mail.</p>
        <br>
        <p>Atenciosamente,<br>Equipe Movies 🎬</p>
      HTML

      # Envia via SendGrid
      SendgridApiMailer.send_email(
        to: resource.email,
        subject: "Redefinição de senha - Movies",
        content: html
      )
    end

    redirect_to new_session_path(resource_name),
                notice: "Se o e-mail existir, um link de redefinição foi enviado."
  end
end
