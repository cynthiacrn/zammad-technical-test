# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

RSpec.describe 'KnowledgeBase translation update', authenticated_as: :current_user, type: :request do
  include_context 'basic Knowledge Base'

  let(:new_title)    { 'new title for update test' }
  let(:current_user) { create(user_identifier) if defined?(user_identifier) }

  let(:params_for_updating) do
    {
      translations_attributes: [
        {
          title:       new_title,
          footer_note: 'new footer',
          id:          knowledge_base.translations.first.id
        }
      ]
    }
  end

  let(:request) do
    patch "/api/v1/knowledge_bases/#{knowledge_base.id}?full=true", params: params_for_updating, as: :json
  end

  describe 'changes KB translation title' do
    describe 'as editor' do
      let(:user_identifier) { :admin }

      it 'updates title' do
        expect { request }.to change { knowledge_base.reload.translations.first.title }.to(new_title)
      end
    end

    describe 'as reader' do
      let(:user_identifier) { :agent }

      it 'does not change title' do
        expect { request }.not_to change { knowledge_base.reload.translations.first.title }
      end
    end

    describe 'as non-KB user' do
      let(:user_identifier) { :customer }

      it 'does not change title' do
        expect { request }.not_to change { knowledge_base.reload.translations.first.title }
      end
    end

    describe 'as a guest' do
      it 'does not change title' do
        expect { request }.not_to change { knowledge_base.reload.translations.first.title }
      end
    end
  end

  describe 'can make request to KB translation' do
    before { request }

    describe 'as editor' do
      let(:user_identifier) { :admin }

      it { expect(response).to have_http_status(:ok) }
      it { expect(json_response).to be_a(Hash) }
    end

    describe 'as reader' do
      let(:user_identifier) { :agent }

      it { expect(response).to have_http_status(:forbidden) }
    end

    describe 'as non-KB user' do
      let(:user_identifier) { :customer }

      it { expect(response).to have_http_status(:forbidden) }
    end

    describe 'as a guest' do
      it { expect(response).to have_http_status(:forbidden) }
    end
  end
end
