require 'app/mailers/application_mailer'

class DocumentMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.document_mailer.pdf_generated.subject
  #
  def pdf_generated file: nil, username: nil, name: nil, email: nil, company: nil
    @greeting = "Hello"
    @username = username
    @name = name
    @email = email

    file ||= CLA.docusign.send :create_pdf, username, name, email, company

    attachments[File.basename(file.path)] = file.read

    mail to: ENV['CONTACT_PROCESS_ONE_TO']
  end

end
