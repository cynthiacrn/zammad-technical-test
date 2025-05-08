# Technical Test Notes

## Environment Setup

During the technical test, I prepared a local development environment using Docker Compose. The setup included the following services:

- **PostgreSQL**: For relational database storage.
- **Redis**: As an in-memory data structure store.
- **Elasticsearch**: For search capabilities.

I also created a `.env` file to manage environment-specific variables cleanly.

## GraphQL Query

As part of the test, I created a GraphQL query to fetch recently created tickets. This can be found in the following file:

`app/graphql/gql/queries/tickets/recently_created.rb`

The query:

- Returns tickets created on the current day.
- Orders them by creation time (descending).
- Accepts an optional `limit` argument (default: 8).
- Restricts access to users with the `ticket.agent` permission.
