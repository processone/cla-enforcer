module CLA
  class DocusignClient
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

      begin
        res  = @client.create_envelope_from_document(
          status: 'sent',
          files: [
            io:   file,
            name: "Contribution License Agreement - #{username}.pdf"
          ],
          email: {
            subject: "ProcessOne Contributor Agreement - #{username}",
            body:    'Please review and sign this document.'
          },
          signers: [{
              name:      name,
              email:     email,
              role_name: ENV['DOCUSIGN_TEMPLATE_ROLE'] || 'Contributor',
              initial_here_tabs: [{
                optional: "false",
                name:            'Initials',
                tab_label:       'Initials',
                tab_order:       1,
                x_position:      '520',
                y_position:      '730',
                page_number:     1
        },
        {
                optional: "false",
                name:            'Initials',
                tab_label:       'Initials',
                tab_order:       2,
                x_position:      '520',
                y_position:      '730',
                page_number:     2
        },
              ],
              radio_group_tabs: [
                group_name: "TypeSelector",
                tab_order:       3,
                radios: [
                  {
                    x_position:      '79',
                    y_position:      '100',
                    page_number:     3,
                    value:           'Individual',
                    selected:        true
                  },
                  {
                    x_position:      '79',
                    y_position:      '131',
                    page_number:     3,
                    value:           'Company'
                  }
                ],
                require_all: 'true',
                shared: 'true'
              ],
              text_tabs: [
                name:            'Address',
                tab_label:       'Address',
                x_position:      '310',
                y_position:      '234',
                width:           '290',
                height:          '45',
                tab_order:       4,
                page_number:     3
              ],
              date_signed_tabs: [
                name:            'Date',
                tab_label:       'Date',
                x_position:      '310',
                y_position:      '290',
                page_number:     Integer(ENV['DOCUSIGN_SIGNATURE_PAGE'] || 3)
              ],
              sign_here_tabs: [
                name:            'Signature',
                tab_label:       'Signature',
                tab_order:       5,
                x_position:      ENV['DOCUSIGN_SIGNATURE_POS_X'] || '293',
                y_position:      ENV['DOCUSIGN_SIGNATURE_POS_Y'] || '305',
                page_number:     Integer(ENV['DOCUSIGN_SIGNATURE_PAGE'] || 3)
              ]
          }],
          event_notification: {
            url:     File.join(@hostname, 'docusign'),
            logging: ENV['RACK_ENV'] == 'development',
            envelope_events: [
              { envelope_event_status_code: 'Completed' },
              { envelope_event_status_code: 'Declined' },
              { envelope_event_status_code: 'Delivered' },
              { envelope_event_status_code: 'Sent' },
              { envelope_event_status_code: 'Voided' }
            ]
          }
        )

        res['envelopeId']
      ensure
        File.unlink(file.path)
      end
    end

    def void_envelope(envelope_id)
      @client.void_envelope({
        envelope_id:   envelope_id,
        voided_reason: "CLA process restarted (Reset button pressed)"
      })
    end

  end
end
