# config/environments/production.rb
require "active_support/core_ext/integer/time"

Rails.application.configure do
  puts "__________________________________________________________"
puts "🟡 [DEBUG ENV CHECK] — Iniciando verificação de variáveis..."
puts "🔸 SENDGRID_API_KEY presente? => #{ENV['SENDGRID_API_KEY'].present?}"
puts "🔸 AWS_ACCESS_KEY_ID presente? => #{ENV['AWS_ACCESS_KEY_ID'].present?}"
puts "🔸 AWS_SECRET_ACCESS_KEY presente? => #{ENV['AWS_SECRET_ACCESS_KEY'].present?}"
puts "🔸 RAILS_ENV => #{Rails.env}"
puts "🔸 Host atual => #{ENV['RENDER_EXTERNAL_HOSTNAME'] || 'sem variável de host'}"
puts "__________________________________________________________"
puts "🚀 Se todos os valores acima estiverem TRUE, variáveis de ambiente OK!"
puts "⚠️ Caso algum esteja FALSE, verifique no painel do Render (Settings → Environment)"
puts "__________________________________________________________"
  # 🚀 Recarregamento desativado (ótimo para produção)
  config.enable_reloading = false
  config.eager_load = true

  # ⚙️ Exibir erros limitados e ativar cache
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # 🚫 Não recompila assets em produção (melhor performance)
  config.assets.compile = false

  # 🖼️ Armazenamento de imagens (Active Storage com Amazon S3)
  config.active_storage.service = :amazon

  # 🌍 Permitir domínio Render
  config.hosts << "movies-felipet.onrender.com"
  config.action_mailer.default_options = { from: "felipe4bfonseca@gmail.com" }

  # 🔐 Força HTTPS (recomendado)
  config.force_ssl = true

  # 🧾 Logs configurados para STDOUT (Render lê daqui)
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [:request_id]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # 💌 Configuração de e-mails (SendGrid)
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp

  # 🔗 URL base usada pelo Devise e ActionMailer
  config.action_mailer.default_url_options = {
    host: "movies-felipet.onrender.com",
    protocol: "https"
  }

  # ✉️ Configuração SMTP do SendGrid
  config.action_mailer.smtp_settings = {
    address:              "smtp.sendgrid.net",
    port:                 587,
    domain:               "movies-felipet.onrender.com",
    user_name:            "apikey",
    password:          ENV["SENDGRID_API_KEY"],
    authentication:       :plain,
    enable_starttls_auto: true
  }

  # 🌎 I18n fallback (usa pt-BR se não achar tradução)
  config.i18n.fallbacks = true

  # 🧹 Desativa logs de avisos deprecados
  config.active_support.report_deprecations = false

  # 🚫 Não exporta schema após migrations
  config.active_record.dump_schema_after_migration = false
end
