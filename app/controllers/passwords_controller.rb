PasswordsControllerclass PasswordsController < Devise::PasswordsController
  def create
    self.resource = resource_class.find_by(email: resource_params[:email])
    if resource
      token = resource.send(:set_reset_password_token)
      url = edit_password_url(resource, reset_password_token: token, locale: I18n.locale)

      html = ApplicationController.render(
        html: "<p>Para redefinir sua senha, clique <a href='#{url}'>aqui</a>.</p>"
      )

      SendgridApiMailer.send_email(
        to: resource.email,
        subject: "Redefinição de senha - Movies",
        content: html
      )
    end
    redirect_to new_session_path(resource_name), notice: "Se o e-mail existir, o link foi enviado."
  end
end
