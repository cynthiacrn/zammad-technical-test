# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

RSpec.describe Sessions::Backend::ActivityStream do
  context 'when async processes affect associated objects / DB records (#2066)' do
    subject(:activity_stream) { described_class.new(user, {}) }

    let(:user)               { create(:agent, groups: [group]) }
    let(:group)              { Group.find_by(name: 'Users') }
    let(:associated_tickets) { create_list(:ticket, ticket_count, group: group) }
    let(:ticket_count)       { 20 }

    before do
      Setting.set('system_init_done', true)

      # these records must be created before the example begins
      # (same as `let!`, but harder to miss)
      associated_tickets
    end

    it 'manages race condition' do
      thread = Thread.new { associated_tickets.each(&:destroy) }
      expect { activity_stream.load }.not_to raise_error
      thread.join
    end
  end
end
