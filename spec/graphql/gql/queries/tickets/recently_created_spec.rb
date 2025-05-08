# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

RSpec.describe Gql::Queries::Tickets::RecentlyCreated, type: :graphql do
  let(:query) do
    <<~GRAPHQL
      query ticketsRecentlyCreated($limit: Int) {
        ticketsRecentlyCreated(limit: $limit) {
          id
        }
      }
    GRAPHQL
  end

  let(:group)  { create(:group) }
  let(:user)   { create(:agent, groups: [group]) }
  let(:limit)  { 5 }
  let(:variables) { { limit: limit } }

  # Tickets created today - should match the query scope
  let!(:matching_tickets) do
    create_list(:ticket, limit + 1, group:, created_at: Time.current, updated_at: Time.current)
  end

  # Ticket created outside of today - should be excluded
  let!(:old_ticket) do
    create(:ticket, group:, created_at: 2.days.ago)
  end

  before do
    gql.execute(query, variables: variables)
  end

  context 'with an agent', authenticated_as: :user do
    it 'returns tickets created today ordered by creation date descending' do
      expected_ids = matching_tickets
                       .sort_by(&:created_at)
                       .reverse
                       .take(limit)
                       .map { |ticket| { 'id' => gql.id(ticket) } }

      expect(gql.result.data).to eq(expected_ids)
    end
  end

  context 'with a customer', authenticated_as: :user do
    let(:user) { create(:customer) }

    it 'raises an error' do
      expect(gql.result.error_type).to eq(Exceptions::Forbidden)
    end
  end

  it_behaves_like 'graphql responds with error if unauthenticated'
end
