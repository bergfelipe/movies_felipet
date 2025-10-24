# config/initializers/devise_mailer_patch.rb
Rails.application.config.to_prepare do
  class Devise::Mailer < Devise.parent_mailer.constantize
    def devise_mail(record, action, opts = {}, &block)
      initialize_from_record(record)
      mail = build_mail(action, opts)

      # Renderiza o template corretamente, mesmo fora do contexto padrão
      html_content = ApplicationController.render(
        template: "devise/mailer/#{action}",
        assigns: instance_values.symbolize_keys
      )

      SendgridApiMailer.send_email(
        to: record.email,
        subject: mail.subject || default_i18n_subject(action: action),
        content: html_content
      )
    rescue => e
      Rails.logger.error("❌ Erro ao enviar e-mail Devise via API: #{e.message}")
    end
  end
end
