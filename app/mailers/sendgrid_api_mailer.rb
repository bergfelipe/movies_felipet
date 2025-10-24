# app/mailers/sendgrid_api_mailer.rb
require "sendgrid-ruby"

class SendgridApiMailer
  include SendGrid

  def self.send_email(to:, subject:, content:)
    from_email = "felipe4bfonseca@gmail.com"
    mail = Mail.new(
      Email.new(email: from_email),
      subject,
      Email.new(email: to),
      Content.new(type: "text/html", value: content)
    )

    sg = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
    response = sg.client.mail._("send").post(request_body: mail.to_json)

    Rails.logger.info("SendGrid API response: #{response.status_code}")
    Rails.logger.info("Response body: #{response.body}") if response.status_code.to_i >= 400
    response
  rescue => e
    Rails.logger.error("SendGrid API ERROR: #{e.message}")
    nil
  end
end
