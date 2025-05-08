import * as Types from '#shared/graphql/types.ts';

import * as Mocks from '#tests/graphql/builders/mocks.ts'
import * as Operations from './ticketsRecentlyCreated.api.ts'
import * as ErrorTypes from '#shared/types/error.ts'

/**
 * Mock a successful response for the `ticketsRecentlyCreated` query.
 */
export function mockTicketsRecentlyCreatedQuery(
  defaults: Mocks.MockDefaultsValue<Types.TicketsRecentlyCreatedQuery, Types.TicketsRecentlyCreatedQueryVariables>
) {
  return Mocks.mockGraphQLResult(Operations.TicketsRecentlyCreatedDocument, defaults);
}

/**
 * Waits for all calls to the `ticketsRecentlyCreated` query.
 */
export function waitForTicketsRecentlyCreatedQueryCalls() {
  return Mocks.waitForGraphQLMockCalls<Types.TicketsRecentlyCreatedQuery>(Operations.TicketsRecentlyCreatedDocument);
}

/**
 * Mock an error for the `ticketsRecentlyCreated` query.
 */
export function mockTicketsRecentlyCreatedQueryError(
  message: string,
  extensions: { type: ErrorTypes.GraphQLErrorTypes }
) {
  return Mocks.mockGraphQLResultWithError(Operations.TicketsRecentlyCreatedDocument, message, extensions);
}
