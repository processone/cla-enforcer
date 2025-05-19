$: << File.expand_path('../../..', __FILE__)
require 'app/mailers/document_mailer'

module CLA
  class SignatureClient
    def initialize(client, agreement_name, hostname)
      @client         = client
      @agreement_name = agreement_name
      @hostname       = hostname
      @cla_template   = ERB.new(
        File.read(File.expand_path('../../templates/cla.html.erb', __FILE__))
      )
    end

    def send_pdf(username, name, email, company)
      file = create_pdf(username, name, email, company)

      DocumentMailer.pdf_generated(username: username, name: name, email: email, company: company, file: file).deliver
    ensure
      File.unlink(file.path)
      puts file.path
    end

    def void_envelope(envelope_id)
      # @client.void_envelope({
      #   envelope_id:   envelope_id,
      #   voided_reason: "CLA process restarted (Reset button pressed)"
      # })
    end

    private

    def create_pdf(username, name, email, company)
      path = Dir.tmpdir + '/' + @agreement_name + ' - ' + username + '.pdf'
      PDFKit.new(@cla_template.result(binding)).to_file(path)
    end

  end
end
