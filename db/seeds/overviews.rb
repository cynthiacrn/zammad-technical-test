# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

overview_role = Role.find_by(name: 'Agent')
Overview.create_if_not_exists(
  name:      __('My Assigned Tickets'),
  link:      'my_assigned',
  prio:      1000,
  role_ids:  [overview_role.id],
  condition: {
    'ticket.state_id' => {
      operator: 'is',
      value:    Ticket::State.by_category_ids(:open),
    },
    'ticket.owner_id' => {
      operator:      'is',
      pre_condition: 'current_user.id',
    },
  },
  order:     {
    by:        'created_at',
    direction: 'ASC',
  },
  view:      {
    d:                 %w[title customer group created_at],
    s:                 %w[title customer group created_at],
    m:                 %w[number title customer group created_at],
    view_mode_default: 's',
  },
)

Overview.create_if_not_exists(
  name:      __('Unassigned & Open Tickets'),
  link:      'all_unassigned',
  prio:      1010,
  role_ids:  [overview_role.id],
  condition: {
    'ticket.state_id' => {
      operator: 'is',
      value:    Ticket::State.by_category_ids(:work_on_all),
    },
    'ticket.owner_id' => {
      operator:      'is',
      pre_condition: 'not_set',
    },
  },
  order:     {
    by:        'created_at',
    direction: 'ASC',
  },
  view:      {
    d:                 %w[title customer group created_at],
    s:                 %w[title customer group created_at],
    m:                 %w[number title customer group created_at],
    view_mode_default: 's',
  },
)

Overview.create_if_not_exists(
  name:      __('My Pending Reached Tickets'),
  link:      'my_pending_reached',
  prio:      1020,
  role_ids:  [overview_role.id],
  condition: {
    'ticket.state_id'     => {
      operator: 'is',
      value:    Ticket::State.by_category_ids(:pending_reminder),
    },
    'ticket.owner_id'     => {
      operator:      'is',
      pre_condition: 'current_user.id',
    },
    'ticket.pending_time' => {
      operator: 'before (relative)',
      value:    0,
      range:    'minute',
    },
  },
  order:     {
    by:        'created_at',
    direction: 'ASC',
  },
  view:      {
    d:                 %w[title customer group created_at],
    s:                 %w[title customer group created_at],
    m:                 %w[number title customer group created_at],
    view_mode_default: 's',
  },
)

Overview.create_if_not_exists(
  name:      __('My Subscribed Tickets'),
  link:      'my_subscribed_tickets',
  prio:      1025,
  role_ids:  [overview_role.id],
  condition: { 'ticket.mention_user_ids'=>{ 'operator' => 'is', 'pre_condition' => 'current_user.id', 'value' => '', 'value_completion' => '' } },
  order:     {
    by:        'created_at',
    direction: 'ASC',
  },
  view:      {
    d:                 %w[title customer group created_at],
    s:                 %w[title customer group created_at],
    m:                 %w[number title customer group created_at],
    view_mode_default: 's',
  },
)

Overview.create_if_not_exists(
  name:      __('Open Tickets'),
  link:      'all_open',
  prio:      1030,
  role_ids:  [overview_role.id],
  condition: {
    'ticket.state_id' => {
      operator: 'is',
      value:    Ticket::State.by_category_ids(:work_on_all),
    },
  },
  order:     {
    by:        'created_at',
    direction: 'ASC',
  },
  view:      {
    d:                 %w[title customer group state owner created_at],
    s:                 %w[title customer group state owner created_at],
    m:                 %w[number title customer group state owner created_at],
    view_mode_default: 's',
  },
)

Overview.create_if_not_exists(
  name:      __('Pending Reached Tickets'),
  link:      'all_pending_reached',
  prio:      1040,
  role_ids:  [overview_role.id],
  condition: {
    'ticket.state_id'     => {
      operator: 'is',
      value:    Ticket::State.by_category_ids(:pending_reminder),
    },
    'ticket.pending_time' => {
      operator: 'before (relative)',
      value:    0,
      range:    'minute',
    },
  },
  order:     {
    by:        'created_at',
    direction: 'ASC',
  },
  view:      {
    d:                 %w[title customer group owner created_at],
    s:                 %w[title customer group owner created_at],
    m:                 %w[number title customer group owner created_at],
    view_mode_default: 's',
  },
)

Overview.create_if_not_exists(
  name:      __('Escalated Tickets'),
  link:      'all_escalated',
  prio:      1050,
  role_ids:  [overview_role.id],
  condition: {
    'ticket.escalation_at' => {
      operator: 'till (relative)',
      value:    '10',
      range:    'minute',
    },
  },
  order:     {
    by:        'escalation_at',
    direction: 'ASC',
  },
  view:      {
    d:                 %w[title customer group owner escalation_at],
    s:                 %w[title customer group owner escalation_at],
    m:                 %w[number title customer group owner escalation_at],
    view_mode_default: 's',
  },
)

Overview.create_if_not_exists(
  name:          __('My Replacement Tickets'),
  link:          'my_replacement_tickets',
  prio:          1080,
  role_ids:      [overview_role.id],
  out_of_office: true,
  condition:     {
    'ticket.state_id'                     => {
      operator: 'is',
      value:    Ticket::State.by_category_ids(:open),
    },
    'ticket.out_of_office_replacement_id' => {
      operator:      'is',
      pre_condition: 'current_user.id',
    },
  },
  order:         {
    by:        'created_at',
    direction: 'DESC',
  },
  view:          {
    d:                 %w[title customer group owner escalation_at],
    s:                 %w[title customer group owner escalation_at],
    m:                 %w[number title customer group owner escalation_at],
    view_mode_default: 's',
  },
)

overview_role = Role.find_by(name: 'Customer')
Overview.create_if_not_exists(
  name:      __('My Tickets'),
  link:      'my_tickets',
  prio:      1100,
  role_ids:  [overview_role.id],
  condition: {
    'ticket.state_id'    => {
      operator: 'is',
      value:    Ticket::State.by_category_ids(:viewable),
    },
    'ticket.customer_id' => {
      operator:      'is',
      pre_condition: 'current_user.id',
    },
  },
  order:     {
    by:        'created_at',
    direction: 'DESC',
  },
  view:      {
    d:                 %w[title customer state created_at],
    s:                 %w[number title state created_at],
    m:                 %w[number title state created_at],
    view_mode_default: 's',
  },
)
Overview.create_if_not_exists(
  name:                __('My Organization Tickets'),
  link:                'my_organization_tickets',
  prio:                1200,
  role_ids:            [overview_role.id],
  organization_shared: true,
  condition:           {
    'ticket.state_id'        => {
      operator: 'is',
      value:    Ticket::State.by_category_ids(:viewable),
    },
    'ticket.organization_id' => {
      operator:      'is',
      pre_condition: 'current_user.organization_id',
    },
  },
  order:               {
    by:        'created_at',
    direction: 'DESC',
  },
  view:                {
    d:                 %w[title customer organization state created_at],
    s:                 %w[number title customer organization state created_at],
    m:                 %w[number title customer organization state created_at],
    view_mode_default: 's',
  },
)
