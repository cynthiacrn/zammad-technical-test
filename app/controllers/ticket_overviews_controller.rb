# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class TicketOverviewsController < ApplicationController
  prepend_before_action :authentication_check

  # GET /api/v1/ticket_overview
  def data

    # get attributes to update
    attributes_to_change = Ticket::ScreenOptions.attributes_to_change(
      view:         'ticket_overview',
      screen:       'overview_bulk',
      current_user: current_user,
    )
    render json: attributes_to_change
  end

  # GET /api/v1/ticket_overviews
  def show

    # get navbar overview data
    if !params[:view]
      index_and_lists = Ticket::Overviews.index(current_user)
      indexes = []
      index_and_lists.each do |index|
        overview = Overview.lookup(id: index[:overview][:id])
        meta = {
          id:    overview.id,
          name:  overview.name,
          prio:  overview.prio,
          link:  overview.link,
          count: index[:count],
        }
        indexes.push meta
      end
      render json: indexes
      return
    end

    index_and_lists = Ticket::Overviews.index(current_user)

    assets = {}
    result = {}
    index_and_lists.each do |index|
      next if index[:overview][:view] != params[:view]

      overview = Overview.lookup(id: index[:overview][:id])
      assets = overview.assets(assets)
      index[:tickets].each do |ticket_meta|
        ticket = Ticket.lookup(id: ticket_meta[:id])
        assets = ticket.assets(assets)
      end
      result = index
    end

    render json: {
      assets: assets,
      index:  result,
    }
  end

end
