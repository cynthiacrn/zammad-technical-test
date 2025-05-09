# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'
require 'models/application_model_examples'
require 'models/concerns/can_be_imported_examples'
require 'models/concerns/can_csv_import_examples'
require 'models/concerns/has_history_examples'
require 'models/concerns/has_object_manager_attributes_examples'
require 'models/ticket/article/has_ticket_contact_attributes_impact_examples'

RSpec.describe Ticket::Article, type: :model do
  subject(:article) { create(:ticket_article) }

  it_behaves_like 'ApplicationModel', can_param: { sample_data_attribute: :body }
  it_behaves_like 'CanBeImported'
  it_behaves_like 'CanCsvImport'
  it_behaves_like 'HasHistory'
  it_behaves_like 'HasObjectManagerAttributes'

  it_behaves_like 'Ticket::Article::HasTicketContactAttributesImpact'

  describe 'Callbacks, Observers, & Async Transactions -' do
    describe 'NULL byte handling (via ChecksAttributeValuesAndLength concern):' do
      it 'removes them from #subject on creation, if necessary (postgres doesn’t like them)' do
        expect(create(:ticket_article, subject: "com test 1\u0000"))
          .to be_persisted
      end

      it 'removes them from #body on creation, if necessary (postgres doesn’t like them)' do
        expect(create(:ticket_article, body: "some\u0000message 123"))
          .to be_persisted
      end
    end

    describe 'Setting of ticket_define_email_from' do
      subject(:article) do
        create(:ticket_article, created_by: created_by, sender_name: 'Agent', type_name: 'email')
      end

      context 'when AgentName' do
        before do
          Setting.set('ticket_define_email_from', 'AgentName')
        end

        context 'with real sender' do
          let(:created_by) { create(:user) }

          it 'sets the from to the realname of the user' do
            expect(article.reload.from).to be_in(
              [
                "#{article.created_by.firstname} #{article.created_by.lastname} <#{article.ticket.group.email_address.email}>",
                "\"#{article.created_by.firstname} #{article.created_by.lastname}\" <#{article.ticket.group.email_address.email}>",
              ]
            )
          end
        end

        context 'with no real sender (e.g. trigger or scheduler)' do
          let(:created_by) { User.find(1) }

          it 'sets the from to realname of the mail address)' do
            expect(article.reload.from).to eq("#{article.ticket.group.email_address.name} <#{article.ticket.group.email_address.email}>")
          end
        end

      end
    end

    describe 'Setting of ticket.create_article_{sender,type}' do
      let!(:ticket) { create(:ticket) }

      context 'on creation' do
        context 'of first article on a ticket' do
          subject(:article) do
            create(:ticket_article, ticket: ticket, sender_name: 'Agent', type_name: 'email')
          end

          it 'sets ticket sender/type attributes based on article sender/type' do
            expect { article }
              .to change { ticket.reload.create_article_sender&.name }.to('Agent')
              .and change { ticket.reload.create_article_type&.name }.to('email')
          end
        end

        context 'of subsequent articles on a ticket' do
          subject(:article) do
            create(:ticket_article, ticket: ticket, sender_name: 'Customer', type_name: 'twitter status')
          end

          let!(:first_article) do
            create(:ticket_article, ticket: ticket, sender_name: 'Agent', type_name: 'email')
          end

          it 'does not modify ticket’s sender/type attributes' do
            expect { article }
              .to not_change { ticket.reload.create_article_sender.name }
              .and not_change { ticket.reload.create_article_type.name }
          end
        end
      end
    end

    describe 'XSS protection:' do
      subject(:article) { create(:ticket_article, body: body, content_type: 'text/html') }

      before do
        # XSS processing may run into a timeout on slow CI systems, so turn the timeout off for the test.
        stub_const("#{HtmlSanitizer}::PROCESSING_TIMEOUT", nil)
      end

      context 'when body contains only injected JS' do
        let(:body) { <<~RAW.chomp }
          <script type="text/javascript">alert("XSS!");</script> some other text
        RAW

        it 'removes <script> tags' do
          expect(article.body).to eq(' some other text')
        end
      end

      context 'when body contains injected JS amidst other text' do
        let(:body) { <<~RAW.chomp }
          please tell me this doesn't work: <script type="text/javascript">alert("XSS!");</script>
        RAW

        it 'removes <script> tags' do
          expect(article.body).to eq(<<~SANITIZED.chomp)
            please tell me this doesn't work:#{' '}
          SANITIZED
        end
      end

      context 'when body contains invalid HTML tags' do
        let(:body) { '<some_not_existing>ABC</some_not_existing>' }

        it 'removes invalid tags' do
          expect(article.body).to eq('ABC')
        end
      end

      context 'when body contains restricted HTML attributes' do
        let(:body) { '<div class="adasd" id="123" data-abc="123"></div>' }

        it 'removes restricted attributes' do
          expect(article.body).to eq('<div></div>')
        end
      end

      context 'when body contains JS injected into href attribute' do
        let(:body) { '<a href="javascript:someFunction()">LINK</a>' }

        it 'removes <a> tags' do
          expect(article.body).to eq('LINK')
        end
      end

      context 'when body contains an unclosed <div> element' do
        let(:body) { '<div>foo' }

        it 'closes it' do
          expect(article.body).to eq('<div>foo</div>')
        end
      end

      context 'when body contains a plain link (<a> element)' do
        let(:body) { '<a href="https://example.com">foo</a>' }

        it 'adds sanitization attributes' do
          expect(article.body).to eq(<<~SANITIZED.chomp)
            <a href="https://example.com" rel="nofollow noreferrer noopener" target="_blank" title="https://example.com">foo</a>
          SANITIZED
        end

        context 'when a sanitization attribute is present' do
          # ATTENTION: We use `target` here because re-sanitization would change the order of attributes
          let(:body) { '<a href="https://example.com" target="_blank">foo</a>' }

          it 'adds sanitization attributes' do
            expect(article.body).to eq(<<~SANITIZED.chomp)
              <a href="https://example.com" rel="nofollow noreferrer noopener" target="_blank" title="https://example.com">foo</a>
            SANITIZED
          end

          context 'when changing an unrelated attribute' do

            it "doesn't re-sanitizes the body" do
              expect { article.update!(message_id: 'test') }.not_to change { article.reload.body }
            end
          end
        end
      end

      context 'for all cases above, combined' do
        let(:body) { <<~RAW.chomp }
          please tell me this doesn't work: <table>ada<tr></tr></table>
          <div class="adasd" id="123" data-abc="123"></div>
          <div>
          <a href="javascript:someFunction()">LINK</a>
          <a href="http://lalal.de">aa</a>
          <some_not_existing>ABC</some_not_existing>
        RAW

        it 'performs all sanitizations' do
          expect(article.body).to eq(<<~SANITIZED.chomp)
            please tell me this doesn't work: <table>ada<tr></tr>
            </table>
            <div></div>
            <div>
            LINK
            <a href="http://lalal.de" rel="nofollow noreferrer noopener" target="_blank" title="http://lalal.de">aa</a>
            ABC
            </div>
          SANITIZED
        end
      end

      context 'for content_type: "text/plain"' do
        subject(:article) { create(:ticket_article, body: body, content_type: 'text/plain') }

        let(:body) { <<~RAW.chomp }
          please tell me this doesn't work: <table>ada<tr></tr></table>
          <div class="adasd" id="123" data-abc="123"></div>
          <div>
          <a href="javascript:someFunction()">LINK</a>
          <a href="http://lalal.de">aa</a>
          <some_not_existing>ABC</some_not_existing>
        RAW

        it 'performs no sanitizations' do
          expect(article.body).to eq(<<~SANITIZED.chomp)
            please tell me this doesn't work: <table>ada<tr></tr></table>
            <div class="adasd" id="123" data-abc="123"></div>
            <div>
            <a href="javascript:someFunction()">LINK</a>
            <a href="http://lalal.de">aa</a>
            <some_not_existing>ABC</some_not_existing>
          SANITIZED
        end
      end

      context 'when body contains <video> element' do
        let(:body) { <<~RAW.chomp }
          please tell me this doesn't work: <video>some video</video><foo>alal</foo>
        RAW

        it 'leaves it as-is' do
          expect(article.body).to eq(<<~SANITIZED.chomp)
            please tell me this doesn't work: <video>some video</video>alal
          SANITIZED
        end
      end

      context 'when body contains CSS in style attribute' do
        context 'for cid-style email attachment' do
          let(:body) { <<~RAW.chomp }
            <img style="width: 85.5px; height: 49.5px" src="cid:15.274327094.140938@zammad.example.com">
            asdasd
            <img src="cid:15.274327094.140939@zammad.example.com">
          RAW

          it 'adds terminal semicolons to style rules' do
            expect(article.body).to eq(<<~SANITIZED.chomp)
              <img style="width: 85.5px; height: 49.5px;" src="cid:15.274327094.140938@zammad.example.com">
              asdasd
              <img src="cid:15.274327094.140939@zammad.example.com">
            SANITIZED
          end
        end

        context 'for relative-path-style email attachment' do
          let(:body) { <<~RAW.chomp }
            <img style="width: 85.5px; height: 49.5px" src="api/v1/ticket_attachment/123/123/123">
            asdasd
            <img src="api/v1/ticket_attachment/123/123/123">
          RAW

          it 'adds terminal semicolons to style rules' do
            expect(article.body).to eq(<<~SANITIZED.chomp)
              <img style="width: 85.5px; height: 49.5px;" src="api/v1/ticket_attachment/123/123/123">
              asdasd
              <img src="api/v1/ticket_attachment/123/123/123">
            SANITIZED
          end
        end
      end

      context 'when body contains <body> elements' do
        let(:body) { '<body>123</body>' }

        it 'removes <body> tags' do
          expect(article.body).to eq('123')
        end
      end

      context 'when body contains onclick attributes in <a> elements' do
        let(:body) { <<~RAW.chomp }
          <a href="#" onclick="some_function();">abc</a>
          <a href="https://example.com" oNclIck="some_function();">123</a>
        RAW

        it 'removes onclick attributes' do
          expect(article.body).to eq(<<~SANITIZED.chomp)
            <a href="#">abc</a>
            <a href="https://example.com" rel="nofollow noreferrer noopener" target="_blank" title="https://example.com">123</a>
          SANITIZED
        end
      end
    end

    describe 'DoS protection:' do
      context 'when #body exceeds 1.5MB' do
        subject(:article) { create(:ticket_article, body: body) }

        let(:body) { 'a' * 2_000_000 }

        context 'for "web" thread', application_handle: 'web' do
          it 'raises an Unprocessable Entity error' do
            expect { article }.to raise_error(Exceptions::UnprocessableEntity)
          end
        end

        context 'for import' do
          before do
            Setting.set('import_mode', true)
          end

          it 'truncates body to 1.5 million chars' do
            expect(article.body.length).to eq(1_500_000)
          end
        end

        context 'for "test.postmaster" thread', application_handle: 'test.postmaster' do
          it 'truncates body to 1.5 million chars' do
            expect(article.body.length).to eq(1_500_000)
          end

          context 'with NULL bytes' do
            let(:body) { "\u0000#{'a' * 2_000_000}" }

            it 'still removes them, if necessary (postgres doesn’t like them)' do
              expect(article).to be_persisted
            end

            it 'still truncates body' do
              expect(article.body.length).to eq(1_500_000)
            end
          end
        end
      end
    end

    describe 'Cti::Log syncing:', performs_jobs: true do
      context 'with existing Log records' do
        context 'for an incoming call from an unknown number' do
          let!(:log) { create(:'cti/log', :with_preferences, from: '491111222222', direction: 'in') }

          context 'with that number in #body' do
            subject(:article) { build(:ticket_article, body: <<~BODY) }
              some message
              +49 1111 222222
            BODY

            it 'does not modify any Log records (because CallerIds from article bodies have #level "maybe")' do
              expect do
                article.save
                perform_enqueued_jobs commit_transaction: true
              end.not_to change { log.reload.attributes }
            end
          end
        end
      end
    end

    describe 'Auto-setting of outgoing Twitter article attributes (via bg jobs):', performs_jobs: true, required_envs: %w[TWITTER_CONSUMER_KEY TWITTER_CONSUMER_SECRET TWITTER_OAUTH_TOKEN TWITTER_OAUTH_TOKEN_SECRET], use_vcr: :with_oauth_headers do
      subject!(:twitter_article) { create(:twitter_article, sender_name: 'Agent') }

      let(:channel) { Channel.find(twitter_article.ticket.preferences[:channel_id]) }

      it 'sets #from to sender’s Twitter handle' do
        expect { perform_enqueued_jobs }
          .to change { twitter_article.reload.from }
          .to('@APITesting001')
      end

      it 'sets #to to recipient’s Twitter handle' do
        expect { perform_enqueued_jobs }
          .to change { twitter_article.reload.to }
          .to('') # Tweet in VCR cassette is addressed to no one
      end

      it 'sets #message_id to tweet ID (https://twitter.com/_/status/<id>)' do
        expect { perform_enqueued_jobs }
          .to change { twitter_article.reload.message_id }
      end

      it 'sets #preferences with tweet metadata' do
        expect { perform_enqueued_jobs }
          .to change { twitter_article.reload.preferences }
          .to(hash_including('twitter', 'links'))

        expect(twitter_article.preferences[:links].first)
          .to include(
            'name'   => 'on Twitter',
            'target' => '_blank',
            'url'    => "https://twitter.com/_/status/#{twitter_article.message_id}"
          )
      end

      it 'does not change #cc' do
        expect { perform_enqueued_jobs }.not_to change { twitter_article.reload.cc }
      end

      it 'does not change #subject' do
        expect { perform_enqueued_jobs }.not_to change { twitter_article.reload.subject }
      end

      it 'does not change #content_type' do
        expect { perform_enqueued_jobs }.not_to change { twitter_article.reload.content_type }
      end

      it 'does not change #body' do
        expect { perform_enqueued_jobs }.not_to change { twitter_article.reload.body }
      end

      it 'does not change #sender' do
        expect { perform_enqueued_jobs }.not_to change { twitter_article.reload.sender }
      end

      it 'does not change #type' do
        expect { perform_enqueued_jobs }.not_to change { twitter_article.reload.type }
      end

      it 'sets appropriate status attributes on the ticket’s channel' do
        expect { perform_enqueued_jobs }
          .to change { channel.reload.attributes }
          .to hash_including(
            'status_in'    => nil,
            'last_log_in'  => nil,
            'status_out'   => 'ok',
            'last_log_out' => ''
          )
      end

      context 'when the original channel (specified in ticket.preferences) was deleted' do
        context 'but a new one with the same screen_name exists' do
          let(:new_channel) { create(:twitter_channel) }

          before do
            channel.destroy

            expect(new_channel.options[:user][:screen_name])
              .to eq(channel.options[:user][:screen_name])
          end

          it 'sets appropriate status attributes on the new channel' do
            expect { perform_enqueued_jobs }
              .to change { new_channel.reload.attributes }
              .to hash_including(
                'status_in'    => nil,
                'last_log_in'  => nil,
                'status_out'   => 'ok',
                'last_log_out' => ''
              )
          end
        end
      end
    end

    describe 'Sending of outgoing emails', performs_jobs: true do
      subject(:article) { create(:ticket_article, type_name: type, sender_name: sender) }

      shared_examples 'sends email' do
        it 'dispatches an email on creation (via TicketArticleCommunicateEmailJob)' do
          expect { article }
            .to have_enqueued_job(TicketArticleCommunicateEmailJob)
        end
      end

      shared_examples 'does not send email' do
        it 'does not dispatch an email' do
          expect { article }
            .not_to have_enqueued_job(TicketArticleCommunicateEmailJob)
        end
      end

      context 'with "application_server" application handle', application_handle: 'application_server' do
        context 'for type: "email"' do
          let(:type) { 'email' }

          context 'from sender: "Agent"' do
            let(:sender) { 'Agent' }

            include_examples 'sends email'
          end

          context 'from sender: "Customer"' do
            let(:sender) { 'Customer' }

            include_examples 'does not send email'
          end
        end

        context 'for any other type' do
          let(:type) { 'sms' }

          context 'from any sender' do
            let(:sender) { 'Agent' }

            include_examples 'does not send email'
          end
        end
      end

      context 'with "*.postmaster" application handle', application_handle: 'scheduler.postmaster' do
        context 'for any type' do
          let(:type) { 'email' }

          context 'from any sender' do
            let(:sender) { 'Agent' }

            include_examples 'does not send email'
          end
        end
      end
    end

    describe '#check_mentions' do
      def text_blob_with(user)
        "Lorem ipsum dolor <a data-mention-user-id='#{user.id}'>#{user.fullname}</a>"
      end

      let(:ticket)              { create(:ticket) }
      let(:agent_with_access)   { create(:agent, groups: [ticket.group]) }
      let(:user_without_access) { create(:agent) }

      let(:passing_body) { text_blob_with(agent_with_access) }
      let(:failing_body) { text_blob_with(user_without_access) }
      let(:partial_body) { text_blob_with(user_without_access) + text_blob_with(agent_with_access) }

      context 'when created in email parsing' do
        before { ApplicationHandleInfo.current = 'postmaster' }

        it 'silently ignores mentions if agent cannot mention users' do
          UserInfo.current_user_id = user_without_access.id
          record = create(:ticket_article, body: passing_body)

          expect(record).to be_persisted
          expect(Mention.count).to be_zero
        end

        it 'silently ignores mentions if given users cannot be mentioned' do
          UserInfo.current_user_id = agent_with_access.id
          article = build(:ticket_article, ticket: ticket, body: failing_body)
          article.save

          expect(article).to be_persisted
          expect(Mention.count).to eq(0)
        end

        it 'silently saves passing user while failing user is skipped' do
          UserInfo.current_user_id = agent_with_access.id

          article = create(:ticket_article, ticket: ticket, body: partial_body)

          expect(article).to be_persisted
          expect(Mention.count).to eq(1)
        end

        it 'mentioned user is added' do
          UserInfo.current_user_id = agent_with_access.id

          create(:ticket_article, ticket: ticket, body: passing_body)

          expect(article).to be_persisted
          expect(Mention.count).to eq(1)
        end
      end

      context 'when created with check_mentions_raises_error set to true' do
        it 'raises an error if agent cannot mention users' do
          UserInfo.current_user_id = create(:customer).id

          article = build(:ticket_article, ticket: ticket, body: passing_body)
          article.check_mentions_raises_error = true

          expect { article.save! }
            .to raise_error(Pundit::NotAuthorizedError)
          expect(Mention.count).to eq(0)
        end

        it 'raises an error if given users cannot be mentioned' do
          UserInfo.current_user_id = agent_with_access.id

          article = build(:ticket_article, ticket: ticket, body: failing_body)
          article.check_mentions_raises_error = true

          expect { article.save! }
            .to raise_error(ActiveRecord::RecordInvalid)
          expect(Mention.count).to eq(0)
        end

        it 'raises an error if one if given users cannot be mentioned' do
          UserInfo.current_user_id = agent_with_access.id

          article = build(:ticket_article, ticket: ticket, body: partial_body)
          article.check_mentions_raises_error = true

          expect { article.save! }
            .to raise_error(ActiveRecord::RecordInvalid)
          expect(Mention.count).to eq(0)
        end

        it 'mentioned user is added' do
          UserInfo.current_user_id = agent_with_access.id

          article = build(:ticket_article, ticket: ticket, body: passing_body)
          article.check_mentions_raises_error = true
          article.save!

          expect(article).to be_persisted
          expect(Mention.count).to eq(1)
        end
      end

      context 'when created with check_mentions_raises_error set to false' do
        it 'silently ignores mentions if agent cannot mention users' do
          UserInfo.current_user_id = create(:customer).id

          article = build(:ticket_article, ticket: ticket, body: failing_body)
          article.save

          expect(article).to be_persisted
          expect(Mention.count).to eq(0)
        end

        it 'silently ignores mentions if given users cannot be mentioned' do
          UserInfo.current_user_id = agent_with_access.id

          article = build(:ticket_article, ticket: ticket, body: failing_body)
          article.save

          expect(article).to be_persisted
          expect(Mention.count).to eq(0)
        end

        it 'silently saves passing user while failing user is skipped' do
          UserInfo.current_user_id = agent_with_access.id

          article = create(:ticket_article, ticket: ticket, body: partial_body)

          expect(article).to be_persisted
          expect(Mention.count).to eq(1)
        end

        it 'mentioned user is added' do
          UserInfo.current_user_id = agent_with_access.id

          create(:ticket_article, ticket: ticket, body: passing_body)

          expect(article).to be_persisted
          expect(Mention.count).to eq(1)
        end
      end
    end

    describe '#check_email_recipient_validity' do
      subject(:article) do
        create(:ticket_article, type_name: type, to: to, check_email_recipient_raises_error: validate)
      end

      let(:type)     { 'email' }
      let(:to)       { nil }
      let(:validate) { false }

      shared_examples 'not raising an error' do
        it 'does not raise an error' do
          expect { article }.not_to raise_error
        end
      end

      shared_examples 'raising an error' do
        it 'raises an error' do
          expect { article }.to raise_error(Exceptions::InvalidAttribute, 'Sending an email without a valid recipient is not possible.')
        end
      end

      context 'when the validation is not explicitly turned on' do
        it_behaves_like 'not raising an error'
      end

      context 'when the validation is explicitly turned on' do
        let(:validate) { true }

        it_behaves_like 'raising an error'

        context 'when the system is in the import mode' do
          before do
            Setting.set('import_mode', true)
          end

          it_behaves_like 'not raising an error'
        end

        context 'when the type is not an email' do
          let(:type) { 'phone' }

          it_behaves_like 'not raising an error'
        end

        context 'when the recipient is empty' do
          let(:to) { '' }

          it_behaves_like 'raising an error'
        end

        context 'when the recipient is unparseable' do
          let(:to) { '@unparseable_address' }

          it_behaves_like 'raising an error'
        end

        context 'when the recipient is not a valid email address' do
          let(:to) { 'not_a_mail' }

          it_behaves_like 'raising an error'
        end

        context 'when multiple recipients are present and at least one is invalid' do
          let(:to) { 'users, test@example.com' }

          it_behaves_like 'raising an error'
        end

        context 'when multiple recipients are present and all are valid' do
          let(:to) { 'users@example.com, test@example.com' }

          it_behaves_like 'not raising an error'
        end
      end
    end
  end

  describe 'clone attachments' do
    context 'of forwarded article' do
      context 'via email' do

        it 'only need to clone attached attachments' do
          article_parent = create(:ticket_article,
                                  type:         Ticket::Article::Type.find_by(name: 'email'),
                                  content_type: 'text/html',
                                  body:         '<img src="cid:15.274327094.140938@zammad.example.com"> some text',)
          create(:store,
                 object:      'Ticket::Article',
                 o_id:        article_parent.id,
                 data:        'content_file1_normally_should_be_an_image',
                 filename:    'some_file1.jpg',
                 preferences: {
                   'Content-Type'        => 'image/jpeg',
                   'Mime-Type'           => 'image/jpeg',
                   'Content-ID'          => '15.274327094.140938@zammad.example.com',
                   'Content-Disposition' => 'inline',
                 })
          create(:store,
                 object:      'Ticket::Article',
                 o_id:        article_parent.id,
                 data:        'content_file2_normally_should_be_an_image',
                 filename:    'some_file2.jpg',
                 preferences: {
                   'Content-Type'        => 'image/jpeg',
                   'Mime-Type'           => 'image/jpeg',
                   'Content-ID'          => '15.274327094.140938_not_reffered@zammad.example.com',
                   'Content-Disposition' => 'inline',
                 })
          create(:store,
                 object:      'Ticket::Article',
                 o_id:        article_parent.id,
                 data:        'content_file3_normally_should_be_an_image',
                 filename:    'some_file3.jpg',
                 preferences: {
                   'Content-Type'        => 'image/jpeg',
                   'Mime-Type'           => 'image/jpeg',
                   'Content-Disposition' => 'attached',
                 })
          article_new = create(:ticket_article)
          UserInfo.current_user_id = 1

          attachments = article_parent.clone_attachments(article_new.class.name, article_new.id, only_attached_attachments: true)

          expect(attachments.count).to eq(2)
          expect(attachments[0].filename).to eq('some_file2.jpg')
          expect(attachments[1].filename).to eq('some_file3.jpg')
        end
      end
    end

    context 'of trigger' do
      context 'via email notifications' do
        it 'only need to clone inline attachments used in body' do
          article_parent = create(:ticket_article,
                                  type:         Ticket::Article::Type.find_by(name: 'email'),
                                  content_type: 'text/html',
                                  body:         '<img src="cid:15.274327094.140938@zammad.example.com"> some text',)
          create(:store,
                 object:      'Ticket::Article',
                 o_id:        article_parent.id,
                 data:        'content_file1_normally_should_be_an_image',
                 filename:    'some_file1.jpg',
                 preferences: {
                   'Content-Type'        => 'image/jpeg',
                   'Mime-Type'           => 'image/jpeg',
                   'Content-ID'          => '15.274327094.140938@zammad.example.com',
                   'Content-Disposition' => 'inline',
                 })
          create(:store,
                 object:      'Ticket::Article',
                 o_id:        article_parent.id,
                 data:        'content_file2_normally_should_be_an_image',
                 filename:    'some_file2.jpg',
                 preferences: {
                   'Content-Type'        => 'image/jpeg',
                   'Mime-Type'           => 'image/jpeg',
                   'Content-ID'          => '15.274327094.140938_not_reffered@zammad.example.com',
                   'Content-Disposition' => 'inline',
                 })

          # #2483 - #{article.body_as_html} now includes attachments (e.g. PDFs)
          # Regular attachments do not get assigned a Content-ID, and should not be copied in this use case
          create(:store,
                 object:      'Ticket::Article',
                 o_id:        article_parent.id,
                 data:        'content_file3_with_no_content_id',
                 filename:    'some_file3.jpg',
                 preferences: {
                   'Content-Type' => 'image/jpeg',
                   'Mime-Type'    => 'image/jpeg',
                 })

          article_new = create(:ticket_article)
          UserInfo.current_user_id = 1

          attachments = article_parent.clone_attachments(article_new.class.name, article_new.id, only_inline_attachments: true)

          expect(attachments.count).to eq(1)
          expect(attachments[0].filename).to eq('some_file1.jpg')
        end
      end
    end
  end

  describe '.summarizable' do
    let(:ticket)    { create(:ticket) }
    let(:article_1) { create(:ticket_article, :system_outbound_email, ticket:) }
    let(:article_2) { create(:ticket_article, :inbound_web, ticket:) }
    let(:article_3) { create(:ticket_article, :outbound_email, ticket:) }

    before { article_1 && article_2 && article_3 }

    it 'filters out System articles' do
      expect(ticket.articles.summarizable).to contain_exactly(article_2, article_3)
    end
  end
end
