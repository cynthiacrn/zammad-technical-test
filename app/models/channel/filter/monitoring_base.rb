# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class Channel::Filter::MonitoringBase
  # according

  # Icinga
  # https://github.com/Icinga/icinga2/blob/master/etc/icinga2/scripts/mail-service-notification.sh
  # http://docs.icinga.org/icinga2/latest/doc/module/icinga2/chapter/monitoring-basics#host-states
  # http://docs.icinga.org/icinga2/latest/doc/module/icinga2/chapter/monitoring-basics#service-states

  # Nagios
  # https://github.com/NagiosEnterprises/nagioscore/blob/754218e67653929a58938b99ef6b6039b6474fe4/sample-config/template-object/commands.cfg.in#L35

  def self.run(_channel, mail, _transaction_params)
    integration = integration_name
    return if !Setting.get("#{integration}_integration")

    sender = Setting.get("#{integration}_sender")
    auto_close = Setting.get("#{integration}_auto_close")
    auto_close_state_id = Setting.get("#{integration}_auto_close_state_id")
    state_ignore_match = Setting.get("#{integration}_ignore_match") || ''
    state_recovery_match = Setting.get("#{integration}_recovery_match") || '(OK|UP)'

    return if mail[:from].blank?
    return if mail[:body].blank?

    session_user_id = mail[ :'x-zammad-session-user-id' ]
    return if !session_user_id

    # check if sender is monitoring
    return if !sender_condition_matching?(mail[:from], sender)

    # get mail attributes like host and state
    result = {}

    mail_body = mail[:body]

    # Convert HTML body to plain text, if needed.
    mail_body = mail_body.html2text if mail[:content_type] == 'text/html'

    mail_body.gsub(%r{(Service(?!\sMetrics)|Host(?!\sMetrics)|State|Address|Date/Time|Additional\sInfo|Info|Action|Description)(?::|\s)(.+?)(\n|$)}i) do |_match|
      key = $1
      if key
        key = key.downcase
      end
      value = $2
      value&.strip!
      result[key] = value
    end

    # check min. params
    return if result['host'].blank?

    # icinga - get state by body - new templates
    if result['state'].blank? && mail_body =~ %r{.+?\sis\s(.+?)!}
      result['state'] = $1
    end

    # icinga - get state by subject - new templates "state:" is not in body anymore
    # Subject: [PROBLEM] Ping IPv4 on host1234.dc.example.com is WARNING!
    # Subject: [PROBLEM] Host host1234.dc.example.com is DOWN!
    if result['state'].blank? && mail[:subject] =~ %r{(on|Host)\s.+?\sis\s(.+?)!}
      result['state'] = $2
    end

    # check_mk - get state by event
    if result['state'].blank? && mail_body =~ %r{\sEvent\s.+?\s→\s(.+?)\s}
      result['state'] = $1
    end

    # monit - get missing attributes from body
    if result['service'].blank? && mail_body =~ %r{\sService\s(.+?)\s}
      result['service'] = $1
    end

    # possible event types https://mmonit.com/monit/documentation/#Setting-an-event-filter
    if result['state'].blank?
      result['state'] = case mail_body
                        when %r{\s(done|recovery|succeeded|bytes\sok|packets\sok)\s}, %r{(instance\schanged\snot|Link\sup|Exists|Saturation\sok|Speed\sok)}
                          'OK'
                        else
                          'CRITICAL'
                        end
    end

    # follow-up detection by meta data
    open_states = Ticket::State.by_category(:open)
    ticket_ids = Ticket.where(state: open_states).reorder(created_at: :desc).limit(5000).pluck(:id)
    ticket_ids.each do |ticket_id|
      ticket = Ticket.find_by(id: ticket_id)
      next if !ticket
      next if !ticket.preferences
      next if !ticket.preferences[integration]
      next if !ticket.preferences[integration]['host']
      next if ticket.preferences[integration]['host'] != result['host']
      next if ticket.preferences[integration]['service'] != result['service']

      # found open ticket for service+host
      mail[ :'x-zammad-ticket-id' ] = ticket.id

      # check if service is recovered
      if auto_close && result['state'].present? && result['state'].match(%r{#{state_recovery_match}}i)
        Rails.logger.info "MonitoringBase.#{integration} set autoclose to state_id #{auto_close_state_id}"
        state = Ticket::State.lookup(id: auto_close_state_id)
        if state
          mail[ :'x-zammad-ticket-followup-state' ] = state.name
        end
      end
      return true
    end

    # new ticket, set meta data
    if !mail[ :'x-zammad-ticket-id' ]
      if !mail[ :'x-zammad-ticket-preferences' ]
        mail[ :'x-zammad-ticket-preferences' ] = {}
      end
      preferences = {}
      preferences[integration] = result
      preferences.each do |key, value|
        mail[ :'x-zammad-ticket-preferences' ][key] = value
      end
    end

    # ignore states
    if state_ignore_match.present? && result['state'].present? && result['state'].match(%r{#{state_ignore_match}}i)
      mail[ :'x-zammad-ignore' ] = true
      return true
    end

    # if now problem exists, just ignore the email
    if result['state'].present? && result['state'].match(%r{#{state_recovery_match}}i)
      mail[ :'x-zammad-ignore' ] = true
      return true
    end

    true
  end

  def self.sender_condition_matching?(from, sender)
    Channel::Filter::Match::Contains.match(value: from, match_rule: sender) || Channel::Filter::Match::EmailRegex.match(value: from, match_rule: sender, check_mode: true)
  end
  private_class_method :sender_condition_matching?
end
