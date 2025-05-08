// Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

import { within } from '@testing-library/vue'
import { describe, it, expect, beforeEach } from 'vitest'

import { visitView } from '#tests/support/components/visitView.ts'
import { mockUserCurrent } from '#tests/support/mock-userCurrent.ts'

import { createDummyTicket } from '#shared/entities/ticket-article/__tests__/mocks/ticket.ts'
import { GraphQLErrorTypes } from '#shared/types/error.ts'

import {
  mockTicketsRecentlyCreatedQuery,
  mockTicketsRecentlyCreatedQueryError,
} from '#desktop/entities/ticket/graphql/queries/ticketsRecentlyCreated.mocks.ts'

describe('DashboardView', () => {
  beforeEach(() => {
    mockUserCurrent({
      id: 'gid://zammad/User/999',
      firstname: 'Nicole',
      lastname: 'Braun',
      fullname: 'Nicole Braun',
      preferences: {},
    })
  })

  it('renders greeting with user name', async () => {
    const view = await visitView('/')

    const greeting = view.getByText('Hello, Nicole Braun!')

    expect(greeting).toBeTruthy()
  })

  describe('tickets created today widget', () => {
    it('shows the tickets-created-today widget', async () => {
      const view = await visitView('/')

      const widget = view.getByTestId('tickets-created-today-widget')
      expect(widget).toBeTruthy()
    })

    // @TODO: renders loading state when query is loading

    it('renders empty state when not tickets queried', async () => {
      mockTicketsRecentlyCreatedQuery({
        ticketsRecentlyCreated: [],
      })

      const view = await visitView('/')

      const widget = view.getByTestId('tickets-created-today-widget')
      const emptyStateTitle = await within(widget).getByText(
        'No new tickets today.',
      )
      expect(emptyStateTitle).toBeTruthy()
    })

    it('renders empty state when query returns error', async () => {
      mockTicketsRecentlyCreatedQueryError('Network error', {
        type: GraphQLErrorTypes.NetworkError,
      })

      const view = await visitView('/')

      const widget = view.getByTestId('tickets-created-today-widget')
      const emptyStateTitle = await within(widget).getByText(
        'No new tickets today.',
      )
      expect(emptyStateTitle).toBeTruthy()
    })

    it('renders the expected number of tickets with correct titles', async () => {
      // Added unique IDs to each dummy to prevent merging issues in mock responses.
      const mockTickets = [
        createDummyTicket({ ticketId: 'alpha-ticket', title: 'Alpha Ticket' }),
        createDummyTicket({ ticketId: 'bravo-ticket', title: 'Bravo Ticket' }),
        createDummyTicket({
          ticketId: 'charlie-ticket',
          title: 'Charlie Ticket',
        }),
      ]

      mockTicketsRecentlyCreatedQuery({
        ticketsRecentlyCreated: mockTickets,
      })

      const view = await visitView('/')

      const widget = view.getByTestId('tickets-created-today-widget')
      const items = await within(widget).findAllByTestId('ticket-created-today')
      expect(items.length).toBe(mockTickets.length)

      const renderedTitles = items.map((item) => {
        const heading = within(item).getByRole('heading', { level: 3 })
        return heading.textContent!.trim()
      })
      const expectedTitles = mockTickets.map((ticket) => ticket.title)

      expectedTitles.forEach((title) => {
        expect(renderedTitles).toContain(title)
      })
    })
  })
})
