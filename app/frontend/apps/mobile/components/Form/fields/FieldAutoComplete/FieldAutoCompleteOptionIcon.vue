<!-- Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
import type { AutoCompleteOption } from '#shared/components/Form/fields/FieldAutocomplete/types.ts'

defineProps<{
  option: AutoCompleteOption
}>()
</script>

<template>
  <CommonIcon
    v-if="option.icon"
    :name="option.icon"
    :class="{
      'opacity-30': option.disabled,
    }"
    class="ltr:mr-4 rtl:ml-4"
  />
</template>
