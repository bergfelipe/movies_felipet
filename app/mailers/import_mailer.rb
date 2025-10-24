# config/initializers/devise_mailer_patch.rb
Rails.application.config.to_prepare do
  class Devise::Mailer < Devise.parent_mailer.constantize
    include SendGrid

    def devise_mail(record, action, opts = {}, &block)
      # Monta o HTML manualmente sem depender do Warden
      begin
        # Carrega as variáveis do template Devise
        @resource = record
        @token = record.send(:set_reset_password_token) if action.to_s == "reset_password_instructions"

        # Renderiza o HTML do template (sem request)
        html_content = ApplicationController.render(
          template: "devise/mailer/#{action}",
          assigns: { resource: @resource, token: @token }
        )

        subject_line = I18n.t("devise.mailer.#{action}.subject", default: "Notificação do Movies")

        SendgridApiMailer.send_email(
          to: record.email,
          subject: subject_line,
          content: html_content
        )
      rescue => e
        Rails.logger.error("❌ Erro ao enviar e-mail Devise via API: #{e.message}")
      end
    end
  end
end
