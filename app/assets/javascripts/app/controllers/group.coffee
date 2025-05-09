class Group extends App.ControllerSubContent
  @requiredPermission: 'admin.group'
  header: __('Groups')
  constructor: ->
    super

    @genericController = new App.ControllerGenericIndex(
      el: @el
      id: @id
      genericObject: 'Group'
      defaultSortBy: 'name'
      searchBar: true
      searchQuery: @search_query
      pageData:
        home: 'groups'
        object: __('Group')
        objects: __('Groups')
        searchPlaceholder: __('Search for groups')
        pagerAjax: true
        pagerBaseUrl: '#manage/groups/'
        pagerSelected: ( @page || 1 )
        pagerPerPage: 50
        navupdate: '#groups'
        notes:     [
          __('Groups are …')
        ]
        buttons: [
          { name: __('New Group'), 'data-type': 'new', class: 'btn--success' }
        ]
      container: @el.closest('.content')
    )

  show: (params) =>
    for key, value of params
      if key isnt 'el' && key isnt 'shown' && key isnt 'match'
        @[key] = value

    @genericController.paginate(@page || 1, params)

App.Config.set('Group', { prio: 1500, name: __('Groups'), parent: '#manage', target: '#manage/groups', controller: Group, permission: ['admin.group'] }, 'NavBarAdmin')
