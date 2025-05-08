<!-- Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
import { computed } from 'vue'

import { QueryHandler } from '#shared/server/apollo/handler/index.ts'

import CommonTicketStateIndicator from '#desktop/components/CommonTicketStateIndicator/CommonTicketStateIndicator.vue'
import { useTicketsRecentlyCreatedQuery } from '#desktop/entities/ticket/graphql/queries/ticketsRecentlyCreated.api.ts'

const ticketsQuery = new QueryHandler(
  useTicketsRecentlyCreatedQuery({ limit: 10 }),
)

const ticketsResult = ticketsQuery.result()
const loading = ticketsQuery.loading()

const tickets = computed(
  () => ticketsResult.value?.ticketsRecentlyCreated ?? [],
)
</script>

<template>
  <div class="mb-4 flex items-center justify-between">
    <div class="flex w-full flex-row items-center justify-between">
      <div class="flex flex-row items-center gap-2.5">
        <CommonIcon
          size="base"
          decorative
          class="pointer-events-none shrink-0"
          name="list"
        />
        <h2 class="text-base font-medium">Recently Created Tickets</h2>
      </div>
    </div>
  </div>

  <div
    v-if="loading"
    class="animate-pulse text-sm text-gray-400 dark:text-neutral-400"
  >
    Loading...
  </div>

  <div v-else-if="!tickets.length" class="text-sm">No new tickets today.</div>

  <ul v-else class="space-y-4 overflow-y-auto">
    <li
      v-for="ticket in tickets"
      :key="ticket.id"
      data-test-id="ticket-created-today"
      class="flex w-full flex-row items-center justify-between"
    >
      <div class="flex flex-row items-center gap-4">
        <CommonDateTime
          :date-time="ticket.createdAt"
          class="hidden text-xs text-gray-200 md:flex dark:text-neutral-500"
        />

        <h3 class="truncate text-sm">
          {{ ticket.title }}
        </h3>
      </div>

      <CommonTicketStateIndicator
        :color-code="ticket.stateColorCode"
        :label="ticket.state.name"
        class="w-fit"
      />
    </li>
  </ul>
</template>
