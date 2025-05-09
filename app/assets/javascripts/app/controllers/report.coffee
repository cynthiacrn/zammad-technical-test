class Reporting extends App.ControllerAppContent
  @requiredPermission: 'report'

  constructor: ->
    super
    @title __('Reporting')
    @navupdate '#report'
    @startLoading()
    @ajax(
      type:  'GET'
      url:   "#{@apiPath}/reports/config"
      processData: true
      success: (data) =>
        @stopLoading()
        if data.error
          @renderScreenError(
            detail:     data.error
            objectName: 'Report'
          )
          return
        @config   = data.config
        @profiles = data.profiles
        @checkStoreParams()

        App.Collection.load(type: 'ReportProfile', data: data.profiles)
        @render()
    )

  getParams: =>
    return @params if @params

    @params = {}
    paramsRaw = @getStoreParams()
    if paramsRaw
      @params = paramsRaw
      return @params

    @params.timeRange = 'year'
    current           = new Date()
    currentDay        = current.getDate()
    currentMonth      = current.getMonth() + 1
    currentYear       = current.getFullYear()
    currentWeek       = current.getWeek()
    @params.day       = currentDay
    @params.month     = currentMonth
    @params.week      = currentWeek
    @params.year      = currentYear
    if !@params.metric
      for key, config of @config.metric
        if config.default
          @params.metric = config.name
    if !@params.backendSelected
      @params.backendSelected = {}
      for key, config of @config.metric
        for backend in config.backend
          if backend.selected
            @params.backendSelected[backend.name] = true
    if !@params.profileSelected
      @params.profileSelected = {}
      for profile in App.ReportProfile.all()
        if _.isEmpty( @params.profileSelected )
          @params.profileSelected[ profile.id ] = true

    @params

  checkStoreParams: =>
    params = @getStoreParams()
    return if _.isEmpty(params)

    configProfileIDs = @profiles.map((profile) -> profile.id)
    storeProfileIDs  = Object.keys(params.profileSelected).map((id) -> parseInt(id))
    return if _.intersection(configProfileIDs, storeProfileIDs).length is storeProfileIDs.length

    App.SessionStorage.delete('report::params')

  getStoreParams: ->
    App.SessionStorage.get('report::params')

  setStoreParams: =>
    # store latest params
    App.SessionStorage.set('report::params', @params)

  render: (data = {}) =>

    @params = @getParams()

    @html App.view('report/main')(
      params: @params
    )

    new TimeRangePicker(
      el:     @el.find('.js-timeRangePicker')
      params: @params
      ui:     @
    )

    new TimePicker(
      el:     @el.find('.js-timePicker')
      params: @params
      ui:     @
    )

    new Sidebar(
      el:     @el.find('.js-aside')
      config: @config
      params: @params
      ui:     @
    )

    new Graph(
      el:     @el
      config: @config
      params: @params
      ui:     @
    )

class Graph extends App.Controller
  constructor: ->
    super

    # rerender view
    @controllerBind('ui:report:rerender', =>
      @render()
    )

    @render()

  update: (data) =>

    # show only selected lines
    dataNew = {}
    for key, value of data.data
      if @params.backendSelected[key] is true
        dataNew[key] = value
      @ui.setStoreParams()

    if !@lastParams
      @lastParams = {}

    return if @lastParams && JSON.stringify(@params) is JSON.stringify(@lastParams)
    @lastParams = $.extend(true, {}, @params)

    @draw(dataNew)
    t = new Date
    @el.find('#download-chart').html(t.toString())
    if @downloadWidget
      @downloadWidget.update(
        config: @config
        params: @params
        ui:     @ui
      )
    else
      @downloadWidget = new Download(
        el:     @el.find('.js-dataDownload')
        config: @config
        params: @params
        ui:     @ui
      )

  render: =>

    url = "#{@apiPath}/reports/generate"
    interval = 5 * 60000
    if @params.timeRange is 'year'
      interval = 5 * 60000
    if @params.timeRange is 'month'
      interval = 60000
    if @params.timeRange is 'week'
      interval = 50000
    if @params.timeRange is 'day'
      interval = 30000
    if @params.timeRange is 'realtime'
      interval = 10000

    @ajax(
      id: 'report_graph'
      type: 'POST'
      url:  url
      data: JSON.stringify(
        metric:    @params.metric
        year:      @params.year
        month:     @params.month
        week:      @params.week
        day:       @params.day
        timeRange: @params.timeRange
        profiles:  @params.profileSelected
        backends:  @params.backendSelected
      )
      processData: true
      error:       (xhr) =>
        return if !_.include([401, 403, 404, 422, 502], xhr.status)

        @bodyModal = new App.ControllerTechnicalErrorModal(
          head:        __('The report could not be generated')
          contentCode: xhr.responseJSON.error
        )
      success: (data) =>
        @update(data)
        @delay(@render, interval, 'report-update', 'page')
    )

  draw: (data) =>
    @log('draw', data)
    $('#placeholder').empty()

    # create xaxis
    xaxis = []
    if @params.timeRange is 'realtime'
      for minute in [0..59]
        xaxis.push [minute, '']
    else if @params.timeRange is 'day'
      for hour in [0..23]
        xaxis.push [hour, hour]
    else if @params.timeRange is 'month'
      for day in [0..30]
        xaxis.push [day, day+1]
    else if @params.timeRange is 'week'
      xaxis = [[0, 'Mon'], [1, 'Tue'], [2, 'Wed'], [3, 'Thr'], [4, 'Fri'], [5, 'Sat'], [6, 'Sun'] ]
    else
      xaxis = [[0, 'Jan'], [1, 'Feb'], [2, 'Mar'], [3, 'Apr'], [4, 'May'], [5, 'Jun'], [6, 'Jul'], [7, 'Aug'], [8, 'Sep'], [9, 'Oct'], [10, 'Nov'], [11, 'Dec']]

    dataPlot = []
    for key, value of data
      realname = key
      if @config.metric[@params.metric]
        for backend in @config.metric[@params.metric].backend
          if backend.name is key
            realname = backend.display
      content = []
      count = 0
      for i in xaxis
        content.push [count, value[count]]
        count += 1

      dataPlot.push {
        data: content
        label: App.i18n.translateInline(realname)
      }

    # plot
    $.plot( $('#placeholder'), dataPlot, {
      yaxis: { min: 0 },
      xaxis: { ticks: xaxis },
      legend: { labelBoxBorderColor: 'var(--ghost-color)' },
      grid: {
        color: 'var(--text-normal)',
        markingsColor: 'var(--background-primary)'
      },
      series: { points: { fillColor: 'var(--background-secondary)' } }
    } )


class Download extends App.Controller
  events:
    'click .js-dataDownloadBackendSelector': 'selectBackend'

  constructor: (data) ->

    # unbind existing click binds
    data.el.off('click .js-dataDownloadBackendSelector')

    super
    @render()

  selectBackend: (e) =>
    e.preventDefault()
    @el.find('.js-dataDownloadBackendSelector').parent().removeClass('active')
    $(e.target).parent().addClass('active')
    @profileSelectedId = $(e.target).data('profile-id')
    @params.downloadBackendSelected = $(e.target).data('backend')
    @ui.setStoreParams()
    @table = false
    @render()

  update: =>
    @render()

  render: =>

    if !@contentRendered
      @contentRendered = true
      @html(App.view('report/download_content')())

    reports = []

    # select first backend, if no backend is selected
    if @config.metric[@params.metric]
      for backend in @config.metric[@params.metric].backend
        if backend.dataDownload && !@params.downloadBackendSelected
          @params.downloadBackendSelected = backend.name
      @ui.setStoreParams()

    # get used profiles
    profiles = []
    for key, value of @params.profileSelected
      if value
        if !@profileSelectedId
          @profileSelectedId = key
        profiles.push App.ReportProfile.find(key)

    downloadHeaderHtml = App.view('report/download_header')(
      reports:                 reports
      profiles:                profiles
      downloadBackendSelected: @params.downloadBackendSelected
      metric:                  @config.metric[@params.metric]
    )
    if downloadHeaderHtml isnt @downloadHeaderHtml
      @el.find('.js-dataDownloadHeader').html(downloadHeaderHtml)
      @downloadHeaderHtml = downloadHeaderHtml

    @tableUpdate()

  tableRender: (tickets, count) =>
    if !@params.downloadBackendSelected
      @$('.js-dataDownloadButton').html('')
      @$('.js-dataDownloadTable').html('')
      return

    profile_id = 0
    for key, value of @params.profileSelected
      if value
        profile_id = key
    downloadUrl = "#{@apiPath}/reports/sets?sheet=true;metric=#{@params.metric};year=#{@params.year};month=#{@params.month};week=#{@params.week};day=#{@params.day};timeRange=#{@params.timeRange};profile_id=#{profile_id};downloadBackendSelected=#{@params.downloadBackendSelected}"

    if count > 0
      @$('.js-dataDownloadButton').html(App.view('report/download_button')(
        count: count
        downloadUrl: downloadUrl
      ))
    else
      @$('.js-dataDownloadButton').html('')

    openTicket = (id,e) =>
      ticket = App.Ticket.findNative(id)
      @navigate ticket.uiUrl()
    callbackTicketTitleAdd = (value, object, attribute, attributes) ->
      attribute.title = object.title
      value
    callbackLinkToTicket = (value, object, attribute, attributes) ->
      attribute.link = object.uiUrl()
      value
    callbackIconHeader = (headers) ->
      attribute =
        name:         'icon'
        display:      ''
        parentClass:  'noTruncate'
        translation:  false
        width:        '28px'
        displayWidth: 28
        unresizable:  true
      headers.unshift(0)
      headers[0] = attribute
      headers
    callbackIcon = (value, object, attribute, header) ->
      value = ' '
      attribute.class  = object.iconClass()
      attribute.link   = ''
      attribute.title  = object.iconTitle()
      value

    params =
      el: @el.find('.js-dataDownloadTable')
      model: App.Ticket
      objects: tickets
      overviewAttributes: ['number', 'title', 'state', 'group', 'created_at']
      bindRow:
        events:
          'click': openTicket
      callbackHeader: [ callbackIconHeader ]
      callbackAttributes:
        icon:
          [ callbackIcon ]
        title:
          [ callbackLinkToTicket, callbackTicketTitleAdd ]
        number:
          [ callbackLinkToTicket, callbackTicketTitleAdd ]

    @table.releaseController() if @table
    @table = new App.ControllerTable(params)

  tableUpdate: =>
    return @tableRender([], 0) if !@params.downloadBackendSelected

    state = {
      metric:                  @params.metric
      year:                    @params.year
      month:                   @params.month
      week:                    @params.week
      day:                     @params.day
      timeRange:               @params.timeRange
      profiles:                @params.profileSelected
      downloadBackendSelected: @params.downloadBackendSelected
    }
    return if _.isEqual(@lastState, state)
    @lastState = $.extend(true, {}, state)

    @ajax(
      id: 'report_download'
      type:  'POST'
      url:   @apiPath + '/reports/sets'
      data: JSON.stringify(state)
      processData: true
      success: (data) =>
        App.Collection.loadAssets(data.assets)
        ticket_collection = []
        if data.ticket_ids
          for record_id in data.ticket_ids
            ticket = App.Ticket.fullLocal(record_id)
            ticket_collection.push ticket
        @tableRender(ticket_collection, data.count)
    )

class TimeRangePicker extends App.Controller
  events:
    'click .js-timeRange': 'select'

  constructor: ->
    super

   # rerender view
    @controllerBind('ui:report:rerender', =>
      @render()
    )

    @render()

  render: =>
    @html App.view('report/time_range_picker')()

    # select time slot
    @el.find('.js-timeRange').removeClass('active')
    @el.find('.js-timeRange[data-type="' + @ui.params.timeRange + '"]').addClass('active')

  select: (e) =>
    e.preventDefault()
    @ui.params.timeRange = $(e.target).data('type')
    App.Event.trigger('ui:report:rerender')


class TimePicker extends App.Controller
  events:
    'click .js-timePickerDay':   'selectTimeDay'
    'click .js-timePickerYear':  'selectTimeYear'
    'click .js-timePickerMonth': 'selectTimeMonth'
    'click .js-timePickerWeek':  'selectTimeWeek'

  constructor: ->
    super

    @_timeSlotPicker()

    # rerender view
    @controllerBind('ui:report:rerender', =>
      @render()
    )
    @render()

  render: =>
    @html App.view('report/time_picker')(
      params:         @ui.params
      timeRangeDay:   @timeRangeDay
      timeRangeMonth: @timeRangeMonth
      timeRangeWeek:  @timeRangeWeek
      timeRangeYear:  @timeRangeYear
    )

    # select time slot
    @el.find('.time-slot').removeClass('active')
    @el.find('.time-slot[data-type="' + @ui.params.timeRange + '"]').addClass('active')

  selectTimeDay: (e) =>
    e.preventDefault()
    @ui.params.day = $(e.target).data('type')
    $(e.target).parent().parent().find('li').removeClass('active')
    $(e.target).parent().addClass('active')
    App.Event.trigger('ui:report:rerender')
    @ui.setStoreParams()

  selectTimeMonth: (e) =>
    e.preventDefault()
    @ui.params.month = $(e.target).data('type')
    $(e.target).parent().parent().find('li').removeClass('active')
    $(e.target).parent().addClass('active')
    App.Event.trigger('ui:report:rerender')
    @ui.setStoreParams()

  selectTimeWeek: (e) =>
    e.preventDefault()
    @ui.params.week = $(e.target).data('type')
    $(e.target).parent().parent().find('li').removeClass('active')
    $(e.target).parent().addClass('active')
    App.Event.trigger('ui:report:rerender')
    @ui.setStoreParams()

  selectTimeYear: (e) =>
    e.preventDefault()
    @ui.params.year = $(e.target).data('type')
    @_timeSlotPicker()
    $(e.target).parent().parent().find('li').removeClass('active')
    $(e.target).parent().addClass('active')
    App.Event.trigger('ui:report:rerender')
    @ui.setStoreParams()

  _timeSlotPicker: ->
    @timeRangeYear = []
    year = new Date().getFullYear()
    for item in [year-2..year]
      record = {
        display: item
        value: item
      }
      @timeRangeYear.push record

    @timeRangeMonth = [
      {
        display: __('Jan')
        value: 1
      },
      {
        display: __('Feb')
        value: 2
      },
      {
        display: __('Mar')
        value: 3
      },
      {
        display: __('Apr')
        value: 4,
      },
      {
        display: __('May')
        value: 5,
      },
      {
        display: __('Jun')
        value: 6,
      },
      {
        display: __('Jul')
        value: 7,
      },
      {
        display: __('Aug')
        value: 8,
      },
      {
        display: __('Sep')
        value: 9,
      },
      {
        display: __('Oct')
        value: 10,
      },
      {
        display: __('Nov')
        value: 11,
      },
      {
        display: __('Dec')
        value: 12,
      },
    ]

    @timeRangeWeek = []

    numberOfWeeks = App.PrettyDate.getISOWeeks(@ui.params.year)

    for item in [1..numberOfWeeks]
      record = {
        display: item
        value: item
      }
      @timeRangeWeek.push record

    @timeRangeDay = []
    for item in [1..31]
      record = {
        display: item
        value: item
      }
      @timeRangeDay.push record


class Sidebar extends App.Controller
  events:
    'click .js-profileSelector': 'selectProfile'
    'click .js-backendSelector': 'selectBackend'
    'click .panel-heading':      'selectMetric'

  constructor: ->
    super
    @render()

  render: =>
    metrics = @config.metric
    profiles = App.ReportProfile.search(filter: { active: true })
    @html App.view('report/sidebar')(
      metrics:  metrics
      params:   @params
      profiles: profiles
    )

  selectMetric: (e) =>
    return if $(e.target).closest('.panel').find('.collapse.in').get(0)
    metric = $(e.target).closest('.panel').data('metric')
    return if @params.metric is metric
    @params.metric                  = metric
    @params.downloadBackendSelected = undefined
    App.Event.trigger('ui:report:rerender')
    @ui.setStoreParams()

  selectProfile: (e) =>
    profile_id = $(e.target).val()
    for key, value of @params.profileSelected
      delete @params.profileSelected[key]
    @params.profileSelected[profile_id] = true
    App.Event.trigger('ui:report:rerender')
    @ui.setStoreParams()

  selectBackend: (e) =>
    backend = $(e.target).val()
    active = $(e.target).prop('checked')
    if active
      @params.backendSelected[backend] = true
    else
      delete @params.backendSelected[backend]
    App.Event.trigger('ui:report:rerender')
    @ui.setStoreParams()

App.Config.set('report', Reporting, 'Routes')
App.Config.set('Reporting', { prio: 8000, parent: '', name: __('Reporting'), translate: true, target: '#report', icon: 'report', permission: ['report'] }, 'NavBarRight')
