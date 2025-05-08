import * as Types from '#shared/graphql/types.ts';

import gql from 'graphql-tag';
import * as VueApolloComposable from '@vue/apollo-composable';
import * as VueCompositionApi from 'vue';
import { SimpleTicketAttributeFragmentDoc } from "#shared/graphql/fragments/simpleTicketAttribute.api.ts";
export type ReactiveFunction<TParam> = () => TParam;

export const TicketsRecentlyCreatedDocument = gql`
query ticketsRecentlyCreated($limit: Int) {
  ticketsRecentlyCreated(limit: $limit) {
    stateColorCode
    ...simpleTicketAttribute
  }
}
${SimpleTicketAttributeFragmentDoc}`;

export function useTicketsRecentlyCreatedQuery(variables: Types.TicketsRecentlyCreatedQueryVariables | VueCompositionApi.Ref<Types.TicketsRecentlyCreatedQueryVariables> | ReactiveFunction<Types.TicketsRecentlyCreatedQueryVariables>, options: VueApolloComposable.UseQueryOptions<Types.TicketsRecentlyCreatedQuery, Types.TicketsRecentlyCreatedQueryVariables> | VueCompositionApi.Ref<VueApolloComposable.UseQueryOptions<Types.TicketsRecentlyCreatedQuery, Types.TicketsRecentlyCreatedQueryVariables>> | ReactiveFunction<VueApolloComposable.UseQueryOptions<Types.TicketsRecentlyCreatedQuery, Types.TicketsRecentlyCreatedQueryVariables>> = {}) {
  return VueApolloComposable.useQuery<Types.TicketsRecentlyCreatedQuery, Types.TicketsRecentlyCreatedQueryVariables>(TicketsRecentlyCreatedDocument, variables, options);
}
