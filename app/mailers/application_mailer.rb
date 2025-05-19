require 'action_mailer'
ActionMailer::Base.view_paths = File.expand_path('../../views/', __FILE__)
ActionMailer::Base.smtp_settings = {
  address: ENV['SMTP_ADDRESS'],
  user_name: ENV['SMTP_USERNAME'],
  password: ENV['SMTP_USERNAME'],
  port: ENV['SMTP_PORT']
}

class ApplicationMailer < ActionMailer::Base
  default from: ENV['CONTACT_PROCESS_ONE_FROM']
  layout "mailer"
end
