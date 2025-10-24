# config/initializers/devise_mailer_patch.rb
Rails.application.config.to_prepare do
  class Devise::Mailer < Devise.parent_mailer.constantize
    include Devise::Controllers::UrlHelpers
    helper Devise::Controllers::UrlHelpers

    def devise_mail(record, action, opts = {}, &block)
      initialize_from_record(record)

      # Gera o HTML do template do Devise (ex: devise/mailer/reset_password_instructions)
      html_content = ApplicationController.render(
        template: "devise/mailer/#{action}",
        assigns: instance_values.symbolize_keys
      )

      subject_line = default_i18n_subject(action: action)

      # Envia via API HTTPS (SendGrid)
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
