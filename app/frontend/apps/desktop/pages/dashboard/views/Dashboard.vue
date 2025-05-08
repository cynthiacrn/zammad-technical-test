<!-- Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
import { computed } from 'vue'

import { QueryHandler } from '#shared/server/apollo/handler/index.ts'
import { useSessionStore } from '#shared/stores/session.ts'

import LayoutMain from '#desktop/components/layout/LayoutMain.vue'
import { useTicketsRecentlyCreatedQuery } from '#desktop/entities/ticket/graphql/queries/ticketsRecentlyCreated.api.ts'

const session = useSessionStore()

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
  <LayoutMain>
    Hello, {{ session.user?.fullname }}!

    <div v-if="loading">Loading...</div>

    <ol v-else>
      <li v-for="ticket in tickets" :key="ticket.id">
        {{ ticket.title }}
      </li>
    </ol>
  </LayoutMain>
</template>
