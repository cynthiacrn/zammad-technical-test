# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'
require 'models/application_model_examples'
require 'models/concerns/can_be_imported_examples'
require 'models/concerns/has_collection_update_examples'
require 'models/concerns/has_xss_sanitized_note_examples'

RSpec.describe Ticket::State, type: :model do
  it_behaves_like 'ApplicationModel'
  it_behaves_like 'CanBeImported'
  it_behaves_like 'HasCollectionUpdate', collection_factory: :ticket_state
  it_behaves_like 'HasXssSanitizedNote', model_factory: :ticket_state

  describe 'Default state' do
    describe 'of whole table:' do
      it 'has default records' do
        expect(described_class.pluck(:name))
          .to contain_exactly('closed', 'merged', 'new', 'open', 'pending close', 'pending reminder')
      end
    end

    describe 'of "new" state:' do
      it 'is the sole #default_create state' do
        expect(described_class.where(default_create: true))
          .to contain_exactly(described_class.find_by(name: 'new'))
      end
    end

    describe 'of "open" state:' do
      it 'is the sole #default_follow_up state' do
        expect(described_class.where(default_follow_up: true))
          .to contain_exactly(described_class.find_by(name: 'open'))
      end
    end
  end

  describe 'Class methods:' do
    describe '.by_category' do
      it 'looks up states by category' do
        expect(described_class.by_category(:open))
          .to be_an(ActiveRecord::Relation)
          .and include(instance_of(described_class))
      end

      context 'with invalid category name' do
        it 'raises ArgumentError' do
          expect { described_class.by_category(:invalidcategoryname) }
            .to raise_error(ArgumentError)
        end
      end
    end
  end

  describe 'Attributes:' do
    describe '#default_create' do
      let!(:original_default) { described_class.find_by(default_create: true) }

      context 'for newly created record' do
        subject!(:state) { build(:ticket_state, default_create: default_create) }

        context 'when true' do
          let(:default_create) { true }

          it 'unsets previous default' do
            expect { state.save }
              .to change { original_default.reload.default_create }.to(false)
              .and not_change { described_class.where(default_create: true).count }
          end
        end

        context 'when false' do
          let(:default_create) { false }

          it 'does not alter existing default' do
            expect { state.save }
              .to not_change { described_class.find_by(default_create: true) }
              .and not_change { described_class.where(default_create: true).count }
          end
        end
      end

      context 'for existing record' do
        subject!(:state) { create(:ticket_state, default_create: default_create) }

        context 'when true' do
          let(:default_create) { true }

          context 'and updated to false' do
            it 'assigns Ticket::State.first as default' do
              expect { state.update(default_create: false) }
                .to change { described_class.first.default_create }.to(true)
                .and not_change { described_class.where(default_create: true).count }
            end
          end

          context 'and destroyed' do
            it 'assigns Ticket::State.first as default' do
              expect { state.destroy }
                .to change { described_class.first.default_create }.to(true)
                .and not_change { described_class.where(default_create: true).count }
            end
          end
        end

        context 'when false' do
          let(:default_create) { false }

          context 'and updated to true' do
            it 'unsets previous default' do
              expect { state.update(default_create: true) }
                .to change { original_default.reload.default_create }.to(false)
                .and not_change { described_class.where(default_create: true).count }
            end
          end

          context 'and destroyed' do
            it 'does not alter existing default' do
              expect { state.destroy }
                .to not_change { described_class.find_by(default_create: true) }
                .and not_change { described_class.where(default_create: true).count }
            end
          end
        end
      end
    end

    describe '#default_follow_up' do
      let!(:original_default) { described_class.find_by(default_follow_up: true) }

      context 'for newly created record' do
        subject!(:state) { build(:ticket_state, default_follow_up: default_follow_up) }

        context 'when true' do
          let(:default_follow_up) { true }

          it 'unsets previous default' do
            expect { state.save }
              .to change { original_default.reload.default_follow_up }.to(false)
              .and not_change { described_class.where(default_follow_up: true).count }
          end
        end

        context 'when false' do
          let(:default_follow_up) { false }

          it 'does not alter existing default' do
            expect { state.save }
              .to not_change { described_class.find_by(default_follow_up: true) }
              .and not_change { described_class.where(default_follow_up: true).count }
          end
        end
      end

      context 'for existing record' do
        subject!(:state) { create(:ticket_state, default_follow_up: default_follow_up) }

        context 'when true' do
          let(:default_follow_up) { true }

          context 'and updated to false' do
            it 'assigns Ticket::State.first as default' do
              expect { state.update(default_follow_up: false) }
                .to change { described_class.first.default_follow_up }.to(true)
                .and not_change { described_class.where(default_follow_up: true).count }
            end
          end

          context 'and destroyed' do
            it 'assigns Ticket::State.first as default' do
              expect { state.destroy }
                .to change { described_class.first.default_follow_up }.to(true)
                .and not_change { described_class.where(default_follow_up: true).count }
            end
          end
        end

        context 'when false' do
          let(:default_follow_up) { false }

          context 'and updated to true' do
            it 'unsets previous default' do
              expect { state.update(default_follow_up: true) }
                .to change { original_default.reload.default_follow_up }.to(false)
                .and not_change { described_class.where(default_follow_up: true).count }
            end
          end

          context 'and destroyed' do
            it 'does not alter existing default' do
              expect { state.destroy }
                .to not_change { described_class.find_by(default_follow_up: true) }
                .and not_change { described_class.where(default_follow_up: true).count }
            end
          end
        end
      end
    end
  end

  describe 'Callbacks' do
    let(:attr) { ObjectManager::Attribute.get(object: 'Ticket', name: 'state_id') }

    before { Setting.set('system_init_done', true) }

    it 'updates state_id attribute when a new state is added' do
      new_state = create(:ticket_state, state_type: Ticket::StateType.lookup(name: 'open'))

      expect(attr.screens)
        .to include(
          'create_middle' => include(
            'ticket.agent'    => include('filter' => include(new_state.id)),
            'ticket.customer' => include('filter' => not_include(new_state.id))
          ),
          'edit'          => include(
            'ticket.agent'    => include('filter' => include(new_state.id)),
            'ticket.customer' => include('filter' => include(new_state.id))
          )
        )
    end

    context 'with an existing state' do
      let(:state) { create(:ticket_state, state_type: Ticket::StateType.lookup(name: 'new')) }

      it 'updates state_id attribute when a state is modified' do
        state.update! state_type: Ticket::StateType.lookup(name: 'open')

        expect(attr.screens)
          .to include(
            'create_middle' => include(
              'ticket.agent'    => include('filter' => include(state.id)),
              'ticket.customer' => include('filter' => not_include(state.id))
            ),
            'edit'          => include(
              'ticket.agent'    => include('filter' => include(state.id)),
              'ticket.customer' => include('filter' => include(state.id))
            )
          )
      end

      it 'updated state_id attribute does not include inactive states (#5268)' do
        state.update! active: false

        expect(attr.screens)
          .to include(
            'create_middle' => include(
              'ticket.agent'    => include('filter' => not_include(state.id)),
              'ticket.customer' => include('filter' => not_include(state.id))
            ),
            'edit'          => include(
              'ticket.agent'    => include('filter' => not_include(state.id)),
              'ticket.customer' => include('filter' => not_include(state.id))
            )
          )
      end

      it 'updates state_id attribute when a state is destroyed' do
        state.destroy!

        expect(attr.screens)
          .to include(
            'create_middle' => include(
              'ticket.agent'    => include('filter' => not_include(state.id)),
              'ticket.customer' => include('filter' => not_include(state.id))
            ),
            'edit'          => include(
              'ticket.agent'    => include('filter' => not_include(state.id)),
              'ticket.customer' => include('filter' => not_include(state.id))
            )
          )
      end
    end
  end

  describe 'Validations' do
    describe 'type uniqueness validation' do
      it 'allows to create multiple open type states' do
        state = build(:ticket_state)
        state.state_type = Ticket::StateType.lookup(name: 'open')
        expect(state).to be_valid
      end

      it 'does not allow to multiple merged type states' do
        state = build(:ticket_state)
        state.state_type = Ticket::StateType.lookup(name: 'merged')
        expect(state).not_to be_valid
      end
    end
  end

  describe '#prevent_merged_state_editing' do
    context 'when state is merged type' do
      it 'prevents editing' do
        state = described_class.find_by name: 'merged'
        expect(state.update(name: 'test')).to be_falsey
      end
    end

    context 'when state is not merged type' do
      it 'allows destruction' do
        state = create(:ticket_state)
        expect(state.update(name: 'test')).to be_truthy
      end
    end
  end

  describe '#prevent_merged_state_destruction' do
    context 'when state is merged type' do
      it 'stops destruction' do
        state = described_class.find_by name: 'merged'
        expect(state.destroy).to be_falsey
      end
    end

    context 'when state is not merged type' do
      it 'allows destruction' do
        state = create(:ticket_state)
        expect(state.destroy).to be_truthy
      end
    end
  end
end
