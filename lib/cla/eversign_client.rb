module CLA
  class EversignClient < SignatureClient
    def initialize(client, agreement_name, hostname)
      @client         = client
      @agreement_name = agreement_name
      @hostname       = hostname
      @cla_template   = ERB.new(
        File.read(File.expand_path('../../templates/cla.html.erb', __FILE__))
      )
    end

    def send_email(username, name, email, company)
      file = create_pdf(username, name, email, company)
      # file = File.new '/Users/sebastienluquet/code/cla-enforcer/Metalhearf_.pdf'

      base_64_file = Base64.encode64(file.read)

      post_body = {
        sandbox: ENV['EVERSIGN_SANDBOX'],
        title: "ProcessOne Contributor Agreement - #{username}",
        message: 'Please review and sign this document.',
        files: [{
          name: "Contribution License Agreement - #{username}.pdf",
          file_base64: base_64_file
        }],
        recipients: [{
          name: ENV['EVERSIGN_RECIPIENT_EMAIL'],
          email: ENV['EVERSIGN_RECIPIENT_EMAIL'],
          language: "fr"
        }],
        signers: [{
          id: 1,
          role: ENV['DOCUSIGN_TEMPLATE_ROLE'] || 'Contributor',
          name: name,
          email: email,
        }],
        fields: [
          [
            {
              "merge": 0,
              "identifier": "unique_field_identifier_5",
              "name": "Signature",
              "options": "",
              "group": "",
              "value": "",
              "type": "signature",
              "x": ENV['DOCUSIGN_SIGNATURE_POS_X'] || '293',
              "y": ENV['DOCUSIGN_SIGNATURE_POS_Y'] || '305',
              "page": Integer(ENV['DOCUSIGN_SIGNATURE_PAGE'] || 3),
              "width": 120,
              "height": 35,
              "signer": 1,
              "validation_type": "",
              "required": 1,
              "readonly": 0,
              "text_size": "",
              "text_color": "",
              "text_style": "",
              "text_font": ""
            },
            {
              "merge": 0,
              "identifier": "unique_field_identifier_6",
              "name": "Date Signed",
              "options": "",
              "group": "",
              "value": "",
              "type": "date_signed",
              "x": '310',
              "y": '290',
              "page": Integer(ENV['DOCUSIGN_SIGNATURE_PAGE'] || 3),
              "width": 60,
              "height": 17,
              "signer": 1,
              "validation_type": "",
              "required": 0,
              "readonly": 0,
              "text_size": "",
              "text_color": "",
              "text_style": "",
              "text_font": ""
            },
            {
              "type": "radio",
              "x": "79",
              "y": "100",
              "width": 14,
              "height": 14,
              "page": Integer(ENV['DOCUSIGN_SIGNATURE_PAGE'] || 3),
              "signer": "1",
              "name": "Individual",
              "identifier": "radio_individual",
              "required": 1,
              "readonly": 0,
              "value": "1",
              "group": "1"
            }, {
              "type": "radio",
              "x": "79",
              "y": "131",
              "width": 14,
              "height": 14,
              "page": Integer(ENV['DOCUSIGN_SIGNATURE_PAGE'] || 3),
              "signer": "1",
              "name": "Company",
              "identifier": "radio_company",
              "required": 1,
              "readonly": 0,
              "value": "",
              "group": "1"
            },
            {
              "type": "note",
              "x": "310",
              "y": "234",
              "width": "290",
              "height": "45",
              "page": Integer(ENV['DOCUSIGN_SIGNATURE_PAGE'] || 3),
              "signer": "1",
              "name": "Address",
              "identifier": "address",
              "required": 1, #TODO
              "readonly": 0,
              "text_size": "",
              "text_color": "",
              "text_font": "",
              "text_style": "",
              "validation_type": "",
              "value": ""
            },
            {
              "type": "initials",
              "x": "520",
              "y": "730",
              "width": "43",
              "height": "43",
              "page": "1",
              "signer": "1",
              "identifier": "initials_1",
              "required": 1
            },
            {
              "type": "initials",
              "x": "520",
              "y": "730",
              "width": "43",
              "height": "43",
              "page": "2",
              "signer": "1",
              "identifier": "initials_2",
              "required": 1
            }
          ]
        ]
      }

      begin
        endpoint = "https://api.eversign.com"
        api_version = "api"
        access_key= ENV['EVERSIGN_KEY']
        business_id = ENV['EVERSIGN_BUSINESS_ID']
        url = "/document?access_key=#{access_key}&business_id=#{business_id}"
        uri = URI.parse("#{endpoint}/#{api_version}#{url}")

        request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
        request.body = post_body.to_json
        http = @client.initialize_net_http_ssl(uri)
        response = http.request(request)

        res = JSON.parse(response.body)

        res['document_hash']
      rescue
      ensure
        File.unlink(file.path)
        puts file.path
      end
    end

    def void_envelope(envelope_id)
      # @client.void_envelope({
      #   envelope_id:   envelope_id,
      #   voided_reason: "CLA process restarted (Reset button pressed)"
      # })
    end

  end
end
