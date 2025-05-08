# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

module Gql::Queries
  class Tickets::RecentlyCreated < BaseQuery

    description 'Fetch tickets recently created'

    argument :limit, Integer, required: false, default_value: 8,
             description: 'Maximum number of tickets to return'

    type [Gql::Types::TicketType], null: false

    def self.authorize(_obj, ctx)
      ctx.current_user.permissions?(['ticket.agent'])
    end

    def resolve(limit:)
      ::Ticket.where(created_at: Time.zone.today.all_day)
              .order(created_at: :desc)
              .limit(limit)
    end
  end
end
