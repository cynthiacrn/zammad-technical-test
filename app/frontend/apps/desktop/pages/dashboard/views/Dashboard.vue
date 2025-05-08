<!-- Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
import { useSessionStore } from '#shared/stores/session.ts'

import LayoutMain from '#desktop/components/layout/LayoutMain.vue'
import CommonWidget from '#desktop/pages/dashboard/components/CommonWidget.vue'
import DashboardGrid from '#desktop/pages/dashboard/components/DashboardGrid.vue'
import TicketsCreatedTodayWidget from '#desktop/pages/dashboard/components/TicketsCreatedTodayWidget.vue'

const session = useSessionStore()
</script>

<template>
  <LayoutMain>
    <div class="flex h-1/10 items-center justify-center text-xl font-medium">
      Hello, {{ session.user?.fullname }}!
    </div>
    <DashboardGrid>
      <CommonWidget
        data-test-id="tickets-created-today-widget"
        class="lg:col-span-2 lg:row-span-2"
      >
        <TicketsCreatedTodayWidget />
      </CommonWidget>
      <CommonWidget class="lg:col-span-1 lg:row-span-1" />
      <CommonWidget class="lg:col-span-1 lg:row-span-1" />
      <CommonWidget class="lg:col-span-2 lg:row-span-1" />
      <CommonWidget class="lg:col-span-1 lg:row-span-2" />
      <CommonWidget class="lg:col-span-2 lg:row-span-1" />
      <CommonWidget class="lg:col-span-1 lg:row-span-1" />
      <CommonWidget class="lg:col-span-1 lg:row-span-1" />
      <CommonWidget class="lg:col-span-1 lg:row-span-1" />
      <CommonWidget class="lg:col-span-1 lg:row-span-1" />
    </DashboardGrid>
  </LayoutMain>
</template>
