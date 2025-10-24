class PasswordsController < Devise::PasswordsController
  def create
    self.resource = resource_class.find_by(email: resource_params[:email])

    if resource.nil?
      flash[:alert] = "❌ Nenhum usuário encontrado com esse e-mail."
      redirect_to new_session_path(resource_name) and return
    end

    # Cria um token de redefinição de senha
    token = resource.send(:set_reset_password_token)
    url = edit_password_url(resource, reset_password_token: token, locale: I18n.locale)

    # Monta o HTML do e-mail — estilizado igual ao modelo original
    html = <<-HTML
  <!DOCTYPE html>
  <html lang="pt-BR">
    <head>
      <meta charset="UTF-8">
      <style>
        body {
          font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
          background-color: #f9fafc;
          color: #333;
          padding: 40px;
          text-align: center;
        }
        .email-container {
          background: #ffffff;
          border-radius: 12px;
          box-shadow: 0 4px 10px rgba(0, 0, 0, 0.08);
          max-width: 520px;
          margin: 0 auto;
          padding: 30px 40px;
        }
        h2 {
          color: #0d6efd;
          margin-bottom: 15px;
        }
        p {
          font-size: 15px;
          line-height: 1.6;
        }
        .footer {
          margin-top: 30px;
          font-size: 13px;
          color: #777;
        }
      </style>
    </head>
    <body>
      <div class="email-container">
        <h2>🔐 Redefinição de senha</h2>

        <p>Olá <strong>#{resource.email}</strong>!</p>
        <p>Recebemos uma solicitação para redefinir sua senha.</p>
        <p>Se foi você, clique no botão abaixo para criar uma nova senha:</p>

        <p>
          <a href="#{url}" 
            style="display:inline-block; margin-top:20px; padding:12px 25px; background-color:#0d6efd; color:#fff; text-decoration:none; font-weight:bold; border-radius:8px;">
            Redefinir minha senha
          </a>
        </p>

        <p class="footer">
          Se você não fez esta solicitação, basta ignorar este e-mail.<br>
          Sua senha permanecerá a mesma até que você acesse o link acima.
        </p>
      </div>
    </body>
  </html>
HTML


    # Envia via SendGrid
    SendgridApiMailer.send_email(
      to: resource.email,
      subject: "🔐 Redefinição de senha — Movies",
      content: html
    )

    redirect_to new_session_path(resource_name),
                notice: "📩 Enviamos um link para redefinir sua senha. Verifique sua caixa de entrada e não esqueça de olhar o Spam!"
  end
end
