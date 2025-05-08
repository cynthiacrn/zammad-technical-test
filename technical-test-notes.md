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

I wrote tests for the dashboard view to verify correct rendering and data usage. These tests are located in:

`app/frontend/apps/desktop/pages/dashboard/__tests__/dashboard.spec.ts`

These tests validate that the dashboard integrates properly with the widget and displays recently created tickets as expected.

## Final Notes

### Challenges & Limitations

- **GraphQL (First-Time Use)**: This was my first experience using GraphQL. It required an initial learning curve to understand the syntax, how queries and mutations are structured, and how they integrate with the backend and authorization layers.
- **Vue.js (Quick Refresher)**: I needed a quick refresher to align with best practices in Vue, particularly around the Composition API and using TypeScript effectively within components.
- **Lack of Familiarity with Existing Architecture**: Initially, it took time to understand how the existing Vue components, GraphQL setup, and shared utilities were structured. This slowed down integration and testing.
- **Testing Setup Complexity**: Setting up frontend tests required navigating the project’s specific test config and mocking strategies. While I eventually added proper tests, this setup process took longer than expected.

### Next Steps & Improvements

- **UI Enhancements**: Improve the user interface of TicketsCreatedTodayWidget.vue by adding loading indicators, empty list messages, and error handling.
- **Internationalization (i18n)**: Add i18n support for the widget title and any user-facing strings to ensure the dashboard is accessible in multiple languages.
- **Responsive Design**: Enhance the layout to be more responsive and mobile-friendly, especially when multiple widgets are displayed in the dashboard grid.
- **Real-Time Updates**: Automatically refresh the ticket list when changes occur, using GraphQL subscriptions (pub/sub) or polling to reflect ticket creation in near real-time.
- **Testing Enhancements**: Add test cases to explicitly cover the loading state of the widget and other edge cases like empty responses or error scenarios.
