<!-- Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
import { computed } from 'vue'

import type { AvatarUser } from '#shared/components/CommonUserAvatar/types.ts'

import UserPopoverWithTrigger from '#desktop/components/User/UserPopoverWithTrigger.vue'

import type { QuickSearchPluginProps } from '../../types.ts'

const props = defineProps<QuickSearchPluginProps>()

const isUserInactive = computed(() => !props.item?.active)
</script>

<template>
  <UserPopoverWithTrigger
    class="group/item flex grow gap-2 rounded-md px-2 py-3 text-neutral-400 hover:bg-blue-900 hover:no-underline!"
    :user="item as AvatarUser"
    :aria-description="isUserInactive ? $t('User is inactive.') : undefined"
  >
    <CommonIcon
      class="shrink-0 text-neutral-500"
      :name="isUserInactive ? 'user-inactive' : 'person'"
      size="small"
      decorative
    />
    <CommonLabel
      class="block! truncate group-hover/item:text-white"
      :class="{
        'text-neutral-500! group-hover/item:text-white!': isUserInactive,
      }"
    >
      {{ item.fullname }}
    </CommonLabel>
  </UserPopoverWithTrigger>
</template>
