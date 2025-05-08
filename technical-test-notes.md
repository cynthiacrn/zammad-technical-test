# Technical Test Notes

## Environment Setup

During the technical test, I prepared a local development environment using Docker Compose. The setup included the following services:

- **PostgreSQL**: For relational database storage.
- **Redis**: As an in-memory data structure store.
- **Elasticsearch**: For search capabilities.

I also created a `.env` file to manage environment-specific variables cleanly.

## Backend GraphQL Query Definition

As part of the test, I created a GraphQL query to fetch recently created tickets. This can be found in the following file:

`app/graphql/gql/queries/tickets/recently_created.rb`

The query:

- Returns tickets created on the current day.
- Orders them by creation time (descending).
- Accepts an optional `limit` argument (default: 8).
- Restricts access to users with the `ticket.agent` permission.

After implementing the query, I ran the `generate-graphql-api` script to update the auto-generated GraphQL schema accordingly.

Additionally, I created a corresponding test for this query located at:

`spec/graphql/gql/queries/tickets/recently_created_spec.rb`

This test was written using existing examples as references and leveraged available helpers to ensure consistency with the project's testing conventions.

## Frontend GraphQL Query Definition

To support frontend usage of the recently created tickets query, I added the API definition in:

`app/frontend/apps/desktop/entities/ticket/graphql/queries/ticketsRecentlyCreated.api.ts`

I also defined the required types for the query in:

`app/frontend/shared/graphql/types.ts`

I used this query in the dashboard view to help with debugging by displaying recently created tickets in a list.

### Component Architecture

To keep the code DRY and modular, I introduced components to better segment logic and UI:

- `TicketsCreatedTodayWidget`: handles the fetching of recently created tickets and displays them in a list with a heading. I moved the fetching logic out of the main dashboard view and into this component to better encapsulate its functionality.
- `CommonWidget`: Wraps the widget component to provide consistent card-style UI.
- `DashboardGrid`: I introduced this component to manage the overall dashboard layout using a bento-style grid, enabling flexible and clean placement of widgets.

This structure improves maintainability and reuse across the dashboard.

## Testing

To support frontend testing, I added mock utilities for the `recentlyCreatedTickets` GraphQL query. These mocks will be used to simulate server responses during component and integration tests, ensuring the widget can be tested independently of backend dependencies. They can be found at:

`app/frontend/apps/desktop/entities/ticket/graphql/queries/ticketsRecentlyCreated.mocks.ts`
