class ProfileTokenAccess extends App.ControllerSubContent
  @requiredPermission: 'user_preferences.access_token'
  header: __('Token Access')
  events:
    'click .js-delete': 'delete'
    'click .js-create': 'create'

  constructor: ->
    super

    @load()
    @interval(
      =>
        @load()
      62000
    )

  # fetch data, render view
  load: (force = false) =>
    @ajax(
      id:    'user_access_token'
      type:  'GET'
      url:   "#{@apiPath}/user_access_token"
      success: (data) =>
        tokens = data.tokens

        # verify is rerender is needed
        if !force && @lastestUpdated && tokens && tokens[0] && @lastestUpdated.updated_at is tokens[0].updated_at
          return
        @lastestUpdated = tokens[0]
        @tokens = data.tokens
        @permissions = data.permissions
        @render()
    )

  render: =>
    @html App.view('profile/token_access')(
      tokens: @tokens
    )

  create: (e) =>
    e.preventDefault()
    new Create(
      container: @el.closest('.content')
      permissions: @permissions
      load: @load
    )

  delete: (e) =>
    e.preventDefault()

    id = $(e.currentTarget).data('token-id')

    callback = =>
      @ajax(
        id:          'user_access_token_delete'
        type:        'DELETE'
        url:         "#{@apiPath}/user_access_token/#{id}"
        processData: true
        success: =>
          @load(true)
        error: @error
      )

    new App.ControllerConfirm(
      message:     __('Are you sure?')
      buttonClass: 'btn--danger'
      callback:    callback
      container:   @el.closest('.content')
    )

  error: (xhr, status, error) =>
    data = JSON.parse(xhr.responseText)
    @notify(
      type: 'error'
      msg:  data.message || data.error
    )

class Create extends App.ControllerModal
  head: __('Add a Personal Access Token')
  buttonSubmit: __('Create')
  buttonCancel: true
  shown: true
  events:
    'change input[name=permission]': 'onToggle'

  content: ->
    # Filter out permissions which are tied to inactivated settings.
    permissions = _.filter(@permissions, (permission) ->
      return true if not permission.preferences?.setting
      App.Config.get(permission.preferences.setting.name) is permission.preferences.setting.value
    )

    content = $(App.view('profile/token_access_create')(
      permissions: permissions
    ))
    datepicker = App.UiElement.date.render(
      name:    'expires_at',
    )
    datepicker.find('.js-datepicker').attr('id', 'token-expires-at')
    content.find('.js-date').html(datepicker)
    content

  onToggle: (e) =>
    isChecked = e.currentTarget.checked
    prefix    = e.currentTarget.value + '.'

    @$(".js-subPermissionList:has(input[value^='#{prefix}'])").toggle(!isChecked)

  onSubmit: (e) =>
    e.preventDefault()
    params = @formParam(e.target)

    # check if min one permission exists
    if _.isEmpty(params['permission'])
      @notify(
        type: 'error'
        msg:  __("The required parameter 'permission' is missing.")
      )
      return

    if !_.isArray(params['permission'])
      params['permission'] = [params['permission']]

    params['permission'] = _.reduce(params['permission'], (memo, permissionName) ->
      startsWithRegex = '^'+permissionName + '\\.'

      _.filter(memo, (elem) -> !elem.match(startsWithRegex))
    , params['permission'])

    @ajax(
      id:          'user_access_token_create'
      type:        'POST'
      url:         "#{@apiPath}/user_access_token"
      data:        JSON.stringify(params)
      processData: true
      success:     @show
      error:       @error
    )

  show: (data) =>
    @load()
    @newToken = data
    @close()

  onClosed: =>
    return if !@newToken
    ui = @
    new App.ControllerModal(
      head: __('Your New Personal Access Token')
      buttonSubmit: __("OK, I've copied my token")
      content: ->
        App.view('profile/token_access_created')(
          token: ui.newToken.token
        )
      onShown: ->
        @$('.js-select').on('click', ui.selectAll)
      onCancel: ->
        @close()
      onSubmit: ->
        @close()
      container: @container
    )

  error: (xhr, status, error) =>
    data = JSON.parse(xhr.responseText)
    @notify(
      type: 'error'
      msg:  data.message || data.error
    )

App.Config.set('Token Access', {
  prio: 3200,
  name: __('Token Access'),
  parent: '#profile',
  target: '#profile/token_access',
  controller: ProfileTokenAccess,
  permission: (controller) ->
    return false if !App.Config.get('api_token_access')
    return controller.permissionCheck('user_preferences.access_token')
}, 'NavBarProfile')
