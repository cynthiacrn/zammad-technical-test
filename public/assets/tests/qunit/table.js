// form
QUnit.test('table test', assert => {
  App.i18n.set('de-de')

  $('#qunit').append('<hr><h1>table simple I</h1><div id="table1"></div>')
  var el = $('#table1')
  App.TicketPriority.refresh( [
    {
      id:         1,
      name:       '1 low',
      note:       'some note 1',
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
    {
      id:         2,
      name:       '2 normal',
      note:       'some note 2',
      active:     false,
      created_at: '2014-06-10T10:17:34.000Z',
    },
  ] )
  var rowClick = function (id, e) {
    e.preventDefault()
    console.log('rowClick', id, e.target)
  };
  var rowDblClick = function (id, e) {
    e.preventDefault()
    console.log('rowDblClick', id, e.target)
  };
  var rowMouseover = function (id, e) {
    e.preventDefault()
    console.log('rowMouseover', id, e.target)
  };
  var rowMouseout = function (id, e) {
    e.preventDefault()
    console.log('rowMouseout', id, e.target)
  };
  var colClick = function (id, e) {
    e.preventDefault()
    console.log('colClick', id, e.target)
  };
  var colDblClick = function (id, e) {
    e.preventDefault()
    console.log('colDblClick', id, e.target)
  };
  var colMouseover = function (id, e) {
    e.preventDefault()
    console.log('colMouseover', id, e.target)
  };
  var colMouseout = function (id, e) {
    e.preventDefault()
    console.log('colMouseout', id, e.target)
  };

  new App.ControllerTable({
    el:       el,
    overview: ['name', 'created_at', 'active'],
    model:    App.TicketPriority,
    objects:  App.TicketPriority.search({sortBy:'name', order: 'ASC'}),
    checkbox: false,
    radio:    false,
    bindRow: {
      events: {
        'click':     rowClick,
        'mouseover': rowMouseover,
        'mouseout':  rowMouseout,
        'dblclick':  rowDblClick,
      }
    },
    bindCol: {
      name: {
        events: {
          'click':     colClick,
          'mouseover': colMouseover,
          'mouseout':  colMouseout,
          'dblclick':  colDblClick,
        }
      },
      created_at: {
        events: {
          'mouseover': colMouseover,
          'mouseout':  colMouseout,
        }
      }
    },
  })
  assert.equal(el.find('table > thead > tr').length, 1, 'row count')
  assert.equal(el.find('table > thead > tr > th:nth-child(1)').text().trim(), 'Name', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(2)').text().trim(), 'Erstellt', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(3)').text().trim(), 'Aktiv', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(4)').text().trim(), 'Aktion', 'check header')
  assert.equal(el.find('tbody > tr:nth-child(1) > td').length, 4, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:first').text().trim(), '1 niedrig', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(2)').text().trim(), '10.06.2014', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3)').text().trim(), 'aktiv', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(4)').text().trim(), '', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td').length, 4, 'check row 2')
  assert.ok(el.find('tbody > tr:nth-child(2) > td:first').text().includes('2 normal'), 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(2)').text().trim(), '10.06.2014', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3)').text().trim(), 'nicht aktiv', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(4)').text().trim(), '', 'check row 2')

  $('#qunit').append('<hr><h1>table simple II</h1><div id="table2"></div>')
  el = $('#table2')
  new App.ControllerTable({
    el:       el,
    overview: ['name', 'created_at', 'active'],
    model:    App.TicketPriority,
    objects:  App.TicketPriority.search({sortBy:'name', order: 'DESC'}),
    checkbox: false,
    radio:    false,
  })
  assert.equal(el.find('table > thead > tr').length, 1, 'row count')
  assert.equal(el.find('table > thead > tr > th:nth-child(1)').text().trim(), 'Name', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(2)').text().trim(), 'Erstellt', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(3)').text().trim(), 'Aktiv', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(4)').text().trim(), 'Aktion', 'check header')
  assert.equal(el.find('tbody > tr:nth-child(1) > td').length, 4, 'check row 1')
  assert.ok(el.find('tbody > tr:nth-child(1) > td:first').text().includes('2 normal'), 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(2)').text().trim(), '10.06.2014', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3)').text().trim(), 'nicht aktiv', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(4)').text().trim(), '', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td').length, 4, 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:first').text().trim(), '1 niedrig', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(2)').text().trim(), '10.06.2014', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3)').text().trim(), 'aktiv', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(4)').text().trim(), '', 'check row 2')

  $('#qunit').append('<hr><h1>table simple III</h1><div id="table3"></div>')
  el = $('#table3')
  new App.ControllerTable({
    el:       el,
    model:    App.TicketPriority,
    objects:  App.TicketPriority.search({sortBy:'created_at', order: 'DESC'}),
    checkbox: false,
    radio:    false,
  })
  assert.equal(el.find('table > thead > tr').length, 1, 'row count')
  assert.equal(el.find('table > thead > tr > th:nth-child(1)').text().trim(), 'Name', 'check header')
  assert.notEqual( el.find('table > thead > tr > th:nth-child(2)').text().trim(), 'Erstellt', 'check header')
  assert.notEqual( el.find('table > thead > tr > th:nth-child(3)').text().trim(), 'Aktiv', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(2)').text().trim(), 'Aktion', 'check header')
  assert.equal(el.find('tbody > tr:nth-child(2) > td').length, 2, 'check row 2')
  assert.ok(el.find('tbody > tr:nth-child(2) > td:first').text().includes('2 normal'), 'check row 2')
  assert.notEqual( el.find('tbody > tr:nth-child(2) > td:nth-child(2)').text().trim(), '?', 'check row 2')
  assert.notEqual( el.find('tbody > tr:nth-child(2) > td:nth-child(3)').text().trim(), 'true', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(2)').text().trim(), '', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(1) > td').length, 2, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:first').text().trim(), '1 niedrig', 'check row 1')
  assert.notEqual( el.find('tbody > tr:nth-child(1) > td:nth-child(2)').text().trim(), '?', 'check row 1')
  assert.notEqual( el.find('tbody > tr:nth-child(1) > td:nth-child(3)').text().trim(), 'false', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(2)').text().trim(), '', 'check row 1')



  App.Group.refresh( [
    {
      id:         1,
      name:       'group 1',
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
    {
      id:         2,
      name:       'group 2',
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
  ])
  App.User.refresh( [
    {
      id:         55,
      login:      'login55',
      firstname:  'firstname55',
      lastname:   'lastname55',
      email:      'email55',
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
    {
      id:         56,
      login:      'login56',
      firstname:  'firstname56',
      lastname:   'lastname56',
      email:      'email56',
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
  ])

  App.TicketState.refresh( [
    {
      id:         1,
      name:       'new',
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
    {
      id:         2,
      name:       'open',
      note:       'some note 2',
      active:     false,
      created_at: '2014-06-10T10:17:34.000Z',
    },
  ])
  App.Ticket.refresh( [
    {
      id:          1,
      title:       'some title 1',
      number:      '4711',
      priority_id: 1,
      owner_id:    55,
      customer_id: 56,
      state_id:    1,
      group_id:    2,
      created_at:  '2014-06-10T11:17:34.000Z',
    },
    {
      id:          3,
      title:       'some title 3',
      number:      '4713',
      priority_id: 2,
      owner_id:    56,
      state_id:    1,
      group_id:    2,
      created_at:  '2014-07-11T11:19:34.000Z',
    },
    {
      id:          2,
      title:       'some title 2',
      number:      '4712',
      priority_id: 1,
      state_id:    2,
      group_id:    1,
      created_at:  '2014-06-10T11:19:34.000Z',
    },
  ])
  $('#qunit').append('<hr><h1>table complex I</h1><div id="table4"></div>')
  el = $('#table4')
  new App.ControllerTable({
    el:       el,
    overview: ['number', 'title', 'owner', 'customer', 'priority', 'group', 'state', 'created_at'],
    model:    App.Ticket,
    objects:  App.Ticket.search({sortBy:'created_at', order: 'DESC'}),
    checkbox: true,
  })
  assert.equal(el.find('table > thead > tr').length, 1, 'row count')
  assert.equal(el.find('table > thead > tr > th:nth-child(1)').text().trim(), '', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(2)').text().trim(), '#', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(3)').text().trim(), 'Titel', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(4)').text().trim(), 'Besitzer', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(5)').text().trim(), 'Kunde', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(6)').text().trim(), 'Priorität', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(7)').text().trim(), 'Gruppe', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(8)').text().trim(), 'Status', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(9)').text().trim(), 'Erstellt am', 'check header')
  assert.equal(el.find('tbody > tr:nth-child(1) > td').length, 9, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(1) input').val(), '3', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(1) input').prop('checked'), '', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(1)').text().trim(), '', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(2)').text().trim(), '4713', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3)').text().trim(), 'some title 3', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(4)').text().trim(), 'firstname56 lastname56', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(5)').text().trim(), '-', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(6)').text().trim(), '2 normal', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(7)').text().trim(), 'group 2', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(8)').text().trim(), 'neu', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(9)').text().trim(), '11.07.2014', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td').length, 9, 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1) input').val(), '2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1) input').prop('checked'), '', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1)').text().trim(), '', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(2)').text().trim(), '4712', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3)').text().trim(), 'some title 2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(4)').text().trim(), '-', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(5)').text().trim(), '-', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(6)').text().trim(), '1 niedrig', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(7)').text().trim(), 'group 1', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(8)').text().trim(), 'offen', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(9)').text().trim(), '10.06.2014', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(3) > td').length, 9, 'check row 3')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(1) input').val(), '1', 'check row 3')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(1) input').prop('checked'), '', 'check row 3')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(1)').text().trim(), '', 'check row 3')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(2)').text().trim(), '4711', 'check row 3')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(3)').text().trim(), 'some title 1', 'check row 3')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(4)').text().trim(), 'firstname55 lastname55', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(5)').text().trim(), 'firstname56 lastname56', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(6)').text().trim(), '1 niedrig', 'check row 3')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(7)').text().trim(), 'group 2', 'check row 3')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(8)').text().trim(), 'neu', 'check row 3')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(9)').text().trim(), '10.06.2014', 'check row 3')

  el.find('input[name="bulk_all"]').trigger('click')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(1) input').prop('checked'), true, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(1) input').val(), '3', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1) input').prop('checked'), true, 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1) input').val(), '2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(1) input').prop('checked'), true, 'check row 3')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(1) input').val(), '1', 'check row 3')

  $('#qunit').append('<hr><h1>table complex II</h1><div id="table5"></div>')
  el = $('#table5')
  var clickCheckbox = function (id, checked, e) {
    console.log('clickCheckbox', id, checked, e.target)
  };
  new App.ControllerTable({
    el:           el,
    overview:     ['number', 'title', 'owner', 'customer', 'priority', 'group', 'state', 'created_at'],
    model:        App.Ticket,
    objects:      App.Ticket.search({sortBy:'created_at', order: 'DESC'}),
    checkbox:     true,
    groupBy:      'group',
    bindCheckbox: {
      events: {
        'click':  clickCheckbox,
      }
    },
  })
  assert.equal(el.find('table > thead > tr').length, 1, 'row count')
  assert.equal(el.find('table > thead > tr > th:nth-child(1)').text().trim(), '', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(2)').text().trim(), '#', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(3)').text().trim(), 'Titel', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(4)').text().trim(), 'Besitzer', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(5)').text().trim(), 'Kunde', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(6)').text().trim(), 'Priorität', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(7)').text().trim(), 'Status', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(8)').text().trim(), 'Erstellt am', 'check header')
  assert.equal(el.find('tbody > tr:nth-child(1) > td').length, 1, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(1)').text().trim(), 'group 1', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td').length, 8, 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1) input').val(), '2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1) input').prop('checked'), '', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1)').text().trim(), '', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(2)').text().trim(), '4712', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3)').text().trim(), 'some title 2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(4)').text().trim(), '-', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(5)').text().trim(), '-', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(6)').text().trim(), '1 niedrig', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(7)').text().trim(), 'offen', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(8)').text().trim(), '10.06.2014', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(3) > td').length, 1, 'check row 3')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(1)').text().trim(), 'group 2', 'check row 4')
  assert.equal(el.find('tbody > tr:nth-child(4) > td').length, 8, 'check row 4')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(1) input').val(), '3', 'check row 4')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(1) input').prop('checked'), '', 'check row 4')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(1)').text().trim(), '', 'check row 4')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(2)').text().trim(), '4713', 'check row 4')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(3)').text().trim(), 'some title 3', 'check row 4')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(4)').text().trim(), 'firstname56 lastname56', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(5)').text().trim(), '-', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(6)').text().trim(), '2 normal', 'check row 4')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(7)').text().trim(), 'neu', 'check row 4')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(8)').text().trim(), '11.07.2014', 'check row 4')

  el.find('input[name="bulk"]:eq(1)').trigger('click')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1) input').prop('checked'), '', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1) input').val(), '2', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(1) input').prop('checked'), true, 'check row 4')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(1) input').val(), '3', 'check row 4')
  assert.equal(el.find('tbody > tr:nth-child(5) > td:nth-child(1) input').prop('checked'), '', 'check row 5')
  assert.equal(el.find('tbody > tr:nth-child(5) > td:nth-child(1) input').val(), '1', 'check row 5')
  el.find('tbody > tr:nth-child(5) > td:nth-child(1) label').trigger('click')
  assert.equal(el.find('tbody > tr:nth-child(5) > td:nth-child(1) input').prop('checked'), true, 'check row 5')
  assert.equal(el.find('tbody > tr:nth-child(5) > td:nth-child(1) input').val(), '1', 'check row 5')


  $('#qunit').append('<hr><h1>table Group By Direction DESC</h1><div id="table6"></div>')
  el = $('#table6')
  var clickCheckbox = function (id, checked, e) {
    console.log('clickCheckbox', id, checked, e.target)
  };
  new App.ControllerTable({
    el:             el,
    overview:       ['number', 'title', 'owner', 'customer', 'priority', 'group', 'state', 'created_at'],
    model:          App.Ticket,
    objects:        App.Ticket.search({sortBy:'created_at', order: 'DESC'}),
    groupBy:        'priority',
    groupDirection: 'DESC',
  })
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(1)').text().trim(), '2 normal', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(3) > td:nth-child(1)').text().trim(), '1 niedrig', 'check row 3')

  $('#qunit').append('<hr><h1>table Group By Direction ASC</h1><div id="table7"></div>')
  el = $('#table7')
  var clickCheckbox = function (id, checked, e) {
    console.log('clickCheckbox', id, checked, e.target)
  };
  new App.ControllerTable({
    el:             el,
    overview:       ['number', 'title', 'owner', 'customer', 'priority', 'group', 'state', 'created_at'],
    model:          App.Ticket,
    objects:        App.Ticket.search({sortBy:'created_at', order: 'DESC'}),
    groupBy:        'priority',
    groupDirection: 'ASC',
  })
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(1)').text().trim(), '1 niedrig', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(4) > td:nth-child(1)').text().trim(), '2 normal', 'check row 4')
});

QUnit.test('table test 2.1', assert => {
  App.i18n.set('de-de')

  $('#qunit').append('<hr><h1>table with hash</h1><div id="table-hash2_1"></div>')
  var el = $('#table-hash2_1')
  App.Group.refresh( [
    {
      id:         5,
      name:       'group 5',
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
  ])

  App.Channel.configure_delete = true
  App.Channel.configure_clone = false
  App.Channel.configure_attributes = [
    { name: 'adapter',            display: 'Type',     tag: 'select',   multiple: false, null: false, options: { IMAP: 'IMAP', POP3: 'POP3' } },
    { name: 'options::host',      display: 'Host',     tag: 'input',    type: 'text', limit: 120, null: true, autocapitalize: false },
    { name: 'options::user',      display: 'User',     tag: 'input',    type: 'text', limit: 120, null: true, autocapitalize: false },
    { name: 'options::password',  display: 'Password', tag: 'input',    type: 'password', limit: 120, null: true, autocapitalize: false },
    { name: 'options::ssl',       display: 'SSL',      tag: 'select',   multiple: false, null: true, options: { true: 'yes', false: 'no' }, translate: true, default: true},
    { name: 'options::folder',    display: 'Folder',   tag: 'input',    type: 'text', limit: 120, null: true, autocapitalize: false },
    { name: 'group_id', display: 'Group', tag: 'tree_select',   multiple: false, null: false, nulloption: true, relation: 'Group'  },
    { name: 'active',             display: 'Active',   tag: 'select',   multiple: false, null: false, options: { true: 'yes', false: 'no' }, translate: true, default: true },
  ]

  App.Channel.refresh( [
    {
      id:      1,
      adapter: 'adapter1',
      options: {
        host: 'host1',
        user: 'user1',
      },
      group_id:   5,
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
    {
      id:      2,
      adapter: 'adapter2',
      options: {
        host: 'host2',
        user: 'user2',
      },
      group_id:   5,
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
  ] )
  new App.ControllerTable({
    el:       el,
    overview: ['adapter', 'options::host', 'options::user', 'active'],
    model:    App.Channel,
    objects:  App.Channel.search({sortBy:'adapter', order: 'ASC'}),
  })
  assert.equal(el.find('table > thead > tr').length, 1, 'row count')
  assert.equal(el.find('table > thead > tr > th:nth-child(1)').text().trim(), 'Typ', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(2)').text().trim(), 'Host', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(3)').text().trim(), 'Benutzer', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(4)').text().trim(), 'Aktiv', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(5)').text().trim(), 'Aktion', 'check header')
  assert.equal(el.find('tbody > tr:nth-child(1) > td').length, 5, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(1)').text().trim(), 'adapter1', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(2)').text().trim(), 'host1', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3)').text().trim(), 'user1', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(4)').text().trim(), 'ja', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(5)').text().trim(), '', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(5) .dropdown.dropdown--actions').length, 0, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(5) .js-delete').length, 1, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(5) .js-clone').length, 0, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td').length, 5, 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1)').text().trim(), 'adapter2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(2)').text().trim(), 'host2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3)').text().trim(), 'user2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(4)').text().trim(), 'ja', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(5)').text().trim(), '', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(5) .dropdown.dropdown--actions').length, 0, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(5) .js-delete').length, 1, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(5) .js-clone').length, 0, 'check row 1')
});

QUnit.test('table test 2.2', assert => {
  App.i18n.set('de-de')

  $('#qunit').append('<hr><h1>table with hash</h1><div id="table-hash2_2"></div>')
  var el = $('#table-hash2_2')
  App.Group.refresh( [
    {
      id:         5,
      name:       'group 5',
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
  ])

  App.Channel.configure_delete = false
  App.Channel.configure_clone = true
  App.Channel.configure_attributes = [
    { name: 'adapter',            display: 'Type',     tag: 'select',   multiple: false, null: false, options: { IMAP: 'IMAP', POP3: 'POP3' } },
    { name: 'options::host',      display: 'Host',     tag: 'input',    type: 'text', limit: 120, null: true, autocapitalize: false },
    { name: 'options::user',      display: 'User',     tag: 'input',    type: 'text', limit: 120, null: true, autocapitalize: false },
    { name: 'options::password',  display: 'Password', tag: 'input',    type: 'password', limit: 120, null: true, autocapitalize: false },
    { name: 'options::ssl',       display: 'SSL',      tag: 'select',   multiple: false, null: true, options: { true: 'yes', false: 'no' }, translate: true, default: true},
    { name: 'options::folder',    display: 'Folder',   tag: 'input',    type: 'text', limit: 120, null: true, autocapitalize: false },
    { name: 'group_id', display: 'Group', tag: 'tree_select',   multiple: false, null: false, nulloption: true, relation: 'Group'  },
    { name: 'active',             display: 'Active',   tag: 'select',   multiple: false, null: false, options: { true: 'yes', false: 'no' }, translate: true, default: true },
  ]

  App.Channel.refresh( [
    {
      id:      1,
      adapter: 'adapter1',
      options: {
        host: 'host1',
        user: 'user1',
      },
      group_id:   5,
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
    {
      id:      2,
      adapter: 'adapter2',
      options: {
        host: 'host2',
        user: 'user2',
      },
      group_id:   5,
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
  ] )
  new App.ControllerTable({
    el:       el,
    overview: ['adapter', 'options::host', 'options::user', 'active'],
    model:    App.Channel,
    objects:  App.Channel.search({sortBy:'adapter', order: 'ASC'}),
  })
  assert.equal(el.find('table > thead > tr').length, 1, 'row count')
  assert.equal(el.find('table > thead > tr > th:nth-child(1)').text().trim(), 'Typ', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(2)').text().trim(), 'Host', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(3)').text().trim(), 'Benutzer', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(4)').text().trim(), 'Aktiv', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(5)').text().trim(), 'Aktion', 'check header')
  assert.equal(el.find('tbody > tr:nth-child(1) > td').length, 5, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(1)').text().trim(), 'adapter1', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(2)').text().trim(), 'host1', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3)').text().trim(), 'user1', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(4)').text().trim(), 'ja', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(5)').text().trim(), '', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(5) .dropdown.dropdown--actions').length, 0, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(5) .js-delete').length, 0, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(5) .js-clone').length, 1, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td').length, 5, 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1)').text().trim(), 'adapter2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(2)').text().trim(), 'host2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3)').text().trim(), 'user2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(4)').text().trim(), 'ja', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(5)').text().trim(), '', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(5) .dropdown.dropdown--actions').length, 0, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(5) .js-delete').length, 0, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(5) .js-clone').length, 1, 'check row 1')
});

QUnit.test('table test 3', assert => {
  App.i18n.set('de-de')

  $('#qunit').append('<hr><h1>table with hash</h1><div id="table-hash2"></div>')
  var el = $('#table-hash2')
  App.Group.refresh( [
    {
      id:         5,
      name:       'group 5',
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
  ])

  App.Channel.configure_delete = true
  App.Channel.configure_clone = true
  App.Channel.configure_attributes = [
    { name: 'adapter',            display: 'Type',     tag: 'select',   multiple: false, null: false, options: { IMAP: 'IMAP', POP3: 'POP3' } },
    { name: 'options::host',      display: 'Host',     tag: 'input',    type: 'text', limit: 120, null: true, autocapitalize: false },
    { name: 'options::user',      display: 'User',     tag: 'input',    type: 'text', limit: 120, null: true, autocapitalize: false },
    { name: 'options::password',  display: 'Password', tag: 'input',    type: 'password', limit: 120, null: true, autocapitalize: false },
    { name: 'options::ssl',       display: 'SSL',      tag: 'select',   multiple: false, null: true, options: { true: 'yes', false: 'no' }, translate: true, default: true},
    { name: 'options::folder',    display: 'Folder',   tag: 'input',    type: 'text', limit: 120, null: true, autocapitalize: false },
    { name: 'group_id', display: 'Group', tag: 'tree_select',   multiple: false, null: false, nulloption: true, relation: 'Group'  },
    { name: 'active',             display: 'Active',   tag: 'select',   multiple: false, null: false, options: { true: 'yes', false: 'no' }, translate: true, default: true },
  ]

  App.Channel.refresh( [
    {
      id:      1,
      adapter: 'adapter1',
      options: {
        host: 'host1',
        user: 'user1',
      },
      group_id:   5,
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
    {
      id:      2,
      adapter: 'adapter2',
      options: {
        host: 'host2',
        user: 'user2',
      },
      group_id:   5,
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
  ] )
  new App.ControllerTable({
    el:       el,
    overview: ['adapter', 'options::host', 'options::user', 'active'],
    model:    App.Channel,
    objects:  App.Channel.search({sortBy:'adapter', order: 'ASC'}),
  })
  assert.equal(el.find('table > thead > tr').length, 1, 'row count')
  assert.equal(el.find('table > thead > tr > th:nth-child(1)').text().trim(), 'Typ', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(2)').text().trim(), 'Host', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(3)').text().trim(), 'Benutzer', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(4)').text().trim(), 'Aktiv', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(5)').text().trim(), 'Aktion', 'check header')
  assert.equal(el.find('tbody > tr:nth-child(1) > td').length, 5, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(1)').text().trim(), 'adapter1', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(2)').text().trim(), 'host1', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3)').text().trim(), 'user1', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(4)').text().trim(), 'ja', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(5) .dropdown.dropdown--actions .js-delete').length, 1, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(5) .dropdown.dropdown--actions .js-clone').length, 1, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td').length, 5, 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1)').text().trim(), 'adapter2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(2)').text().trim(), 'host2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3)').text().trim(), 'user2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(4)').text().trim(), 'ja', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(5) .dropdown.dropdown--actions .js-delete').length, 1, 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(5) .dropdown.dropdown--actions .js-clone').length, 1, 'check row 2')
});

QUnit.test('table test 4', assert => {
  App.i18n.set('de-de')

  $('#qunit').append('<hr><h1>table with link</h1><div id="table-link1"></div>')
  var el = $('#table-link1')
  App.EmailAddress.refresh( [
    {
      id:         55,
      name:       'realname 55',
      email:      'email 55',
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
    {
      id:         56,
      name:       'realname 56',
      email:      'email 56',
      active:     true,
      created_at: '2014-06-10T11:17:34.000Z',
    },
  ])
  var callbackHeader = function (header) {
    console.log('current header is', header);
    // add new header item
    var attribute = {
      name:    'some name',
      display: 'Some Name',
    };
    header.push(attribute);
    console.log('new header is', header);
    return header
  }
  var callbackAttributes = function(value, object, attribute, header, refObject) {
    console.log('data of item col', value, object, attribute, header, refObject)
    value           = ' '
    attribute.class = 'glyphicon glyphicon-user'
    attribute.link  = '#'
    attribute.title = App.i18n.translateInline('Current User')
    if (object.id == 55) {
      attribute.data = {
        some: 'value55',
        xxx:  55,
      }
    }
    else {
      attribute.data = {
        some: 'value56',
        xxx:  56,
      }
    }
    return value
  }
  var switchTo = function(id, e) {
    e.preventDefault()
    console.log('switchTo with id', id, e.target)
    //@disconnectClient()
    //App.Auth._logout()
    //window.location = App.Config.get('api_path') + '/sessions/switch/' + id
  }
  new App.ControllerTable({
    el:                 el,
    model:              App.EmailAddress,
    objects:            App.EmailAddress.search({sortBy:'name', order: 'ASC'}),
    callbackHeader:     [callbackHeader],
    callbackAttributes: {
      'some name': [ callbackAttributes ]
    },
    bindCol: {
      'some name': {
         events: {
           'click': switchTo,
         }
      },
    },
  })
  assert.equal(el.find('table > thead > tr').length, 1, 'row count')
  assert.equal(el.find('table > thead > tr > th:nth-child(1)').text().trim(), 'Anzeigename', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(3)').text().trim(), 'Some Name', 'check header')
  assert.equal(el.find('tbody > tr:nth-child(1) > td').length, 3, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(1)').text().trim(), 'realname 55', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(2)').text().trim(), 'email 55', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3)').text().trim(), '', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3) > a > span').hasClass('glyphicon-user'), true, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3) > a > span').hasClass('glyphicon'), true, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3)').attr('title'), 'Aktueller Benutzer', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3) > a > span').data('some'), 'value55', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3) > a > span').data('xxx'), '55', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td').length, 3, 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(1)').text().trim(), 'realname 56', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(2)').text().trim(), 'email 56', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3)').text().trim(), '', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3) > a > span').hasClass('glyphicon-user'), true, 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3) > a > span').hasClass('glyphicon'), true, 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3)').attr('title'), 'Aktueller Benutzer', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3) > a > span').data('some'), 'value56', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3) > a > span').data('xxx'), '56', 'check row 2')

});

QUnit.test('table test 5', assert => {
  App.i18n.set('de-de')

  $('#qunit').append('<hr><h1>table with data</h1><div id="table-data1"></div>')
  var el = $('#table-data1')

  data = [
    { name: 'some name 1', data: 'some data 1', active: true },
    { name: 'some name 2', data: 'some data 2', active: false },
    { name: 'some name 3', data: 'some data 3', active: true },
  ]
  new App.ControllerTable({
    el:       el,
    overview: ['name', 'data', 'active'],
    attribute_list: [
      { name: 'name',     display: 'Name',      type: 'text', style: 'width: 10%' },
      { name: 'data',     display: 'Data',      type: 'text' },
      { name: 'active',   display: 'Active',    type: 'text' },
    ],
    objects: data
  });

  assert.equal(el.find('table > thead > tr').length, 1, 'row count')
  assert.equal(el.find('table > thead > tr > th:nth-child(1)').text().trim(), 'Name', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(2)').text().trim(), 'Data', 'check header')
  assert.equal(el.find('table > thead > tr > th:nth-child(3)').text().trim(), 'Aktiv', 'check header')
  assert.equal(el.find('tbody > tr:nth-child(1) > td').length, 3, 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:first').text().trim(), 'some name 1', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(2)').text().trim(), 'some data 1', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(1) > td:nth-child(3)').text().trim(), 'true', 'check row 1')
  assert.equal(el.find('tbody > tr:nth-child(2) > td').length, 3, 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:first').text().trim(), 'some name 2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(2)').text().trim(), 'some data 2', 'check row 2')
  assert.equal(el.find('tbody > tr:nth-child(2) > td:nth-child(3)').text().trim(), 'false', 'check row 2')
});

QUnit.test('table test 6/7', assert => {
  $('#qunit').append('<hr><h1>sotable table with data</h1><div id="table-data6"></div>')
  var el_head_sortable = $('#table-data6')

  $('#qunit').append('<hr><h1>not sortable table with data</h1><div id="table-data7"></div>')
  var el_not_head_sortable = $('#table-data7')

  data = [
    { name: 'a item', data: 'g data', active: true },
    { name: 'b item', data: 'b data', active: false },
    { name: 'c item', data: 'z data', active: false },
    { name: 'd item', data: '', active: false },
  ]

  new App.ControllerTable({
    tableId:  'a',
    el:       el_head_sortable,
    overview: ['name', 'data', 'active'],
    attribute_list: [
      { name: 'name',     display: 'Name',      type: 'text', style: 'width: 10%', unsortable: true },
      { name: 'data',     display: 'Data',      type: 'text' },
      { name: 'active',   display: 'Active',    type: 'text' },
    ],
    objects: data
  });

  new App.ControllerTable({
    tableId:  'b',
    el:       el_not_head_sortable,
    overview: ['name', 'data', 'active'],
    attribute_list: [
      { name: 'name',     display: 'Name',      type: 'text', style: 'width: 10%', unsortable: true },
      { name: 'data',     display: 'Data',      type: 'text' },
      { name: 'active',   display: 'Active',    type: 'text' },
    ],
    objects: data,
    dndCallback: function() { return true }
  });

  assert.equal(el_head_sortable.find('tbody > tr:nth-child(1) > td:first').text().trim(), 'a item', 'check row 1')
  assert.equal(el_not_head_sortable.find('tbody > tr:nth-child(1) > td:nth-child(2)').text().trim(), 'a item', 'check row 1')

  assert.ok(_.isEqual(list_items(el_head_sortable, 1), ['a item', 'b item', 'c item', 'd item']), 'sortable table is rendered correctly')
  assert.ok(_.isEqual(list_items(el_not_head_sortable, 2), ['a item', 'b item', 'c item', 'd item']), 'unsortable table is rendered correctly')

  click_sort(el_head_sortable, 2)
  click_sort(el_not_head_sortable, 3)

  assert.ok(_.isEqual(list_items(el_head_sortable, 1), ['b item', 'a item', 'c item', 'd item']), 'sortable table is sorted')
  assert.ok(_.isEqual(list_items(el_not_head_sortable, 2), ['a item', 'b item', 'c item', 'd item']), 'unsortable table is not sorted')

  click_sort(el_head_sortable, 3)
  assert.ok(_.isEqual(list_items(el_head_sortable, 1), ['b item', 'c item', 'd item', 'a item']), 'sorting by boolean column works')

  click_sort(el_head_sortable, 1)
  assert.ok(_.isEqual(list_items(el_head_sortable, 1), ['b item', 'c item', 'd item', 'a item']), 'sorting on name column is disabled')
});

QUnit.test('table test 8 - double escaping for translatables', assert => {
  $('#qunit').append('<hr><h1>table with translated and escapable data</h1><div id="table-data8"></div>')
  var el = $('#table-data8')

  data = [
    { name: 'some name 1', data: 'some data 1' },
    { name: 'some "name" 2', data: 'some data 2' },
    { name: 'some name 3', data: 'some data 3' },
  ]
  new App.ControllerTable({
    el:       el,
    overview: ['name', 'data', 'active'],
    attribute_list: [
      { name: 'name', display: 'Name', type: 'text', tag: 'input', translate: true },
      { name: 'data', display: 'Data', type: 'text' },
    ],
    objects: data
  });

  assert.equal(el.find('tbody > tr:nth-child(2) > td:first-child').text().trim(), 'some "name" 2', 'check translated name with quotes')
});

QUnit.test('Overview grouping does not work with multi_tree_select #4408', assert => {
  $('#qunit').append('<hr><h1>Overview grouping does not work with multi_tree_select #4408</h1><div id="table-data9"></div>')
  var el = $('#table-data9')

  data = [
    { name: 'some name 1', data: ['some data 1'] },
    { name: 'some "name" 2', data: ['some data 2', 'some data 3'] },
    { name: 'some name 3', data: ['some data 3', 'some data 2'] },
  ]
  new App.ControllerTable({
    el:       el,
    overview: ['name', 'data', 'active'],
    attribute_list: [
      { name: 'name', display: 'Name', type: 'text', tag: 'input', translate: true },
      { name: 'data', display: 'Data', type: 'multi_tree_select' },
    ],
    groupBy: 'data',
    objects: data
  });

  assert.equal(el.find('tbody > tr > td[colspan=1]').length, 2, '#4408 - element count')
  assert.deepEqual(el.find('tbody > tr > td[colspan=1]').map(function() { return $(this).text() }).get(), ['some data 1', 'some data 2, some data 3'], '#4408 - correct group descriptions')
});

QUnit.test('Table - numeric sort', assert => {
  $('#qunit').append('<hr><h1>Table - numeric sort</h1><div id="table-data10"></div>')
  var el = $('#table-data10')

  object_data = [
    { number: 4501, title: 'Ticket 10', time_unit: 10 },
    { number: 4502, title: 'Ticket 25', time_unit: 25 },
    { number: 4503, title: 'Ticket 50', time_unit: 50 },
  ]

  new App.ControllerTable({
    tableId:        'numericsort',
    el:             el,
    overview:       ['number', 'title', 'time_unit'],
    attribute_list: [
      { name: 'number', display: '#', tag: 'input', type: 'text', limit: 100, null: true, readonly: 1, width: '68px' },
      { name: 'title', display: 'Title', tag: 'input', type: 'text', limit: 100, null: false },
      { name: 'time_unit', display: 'Accounted Time', readonly: 1, width: '12%', tag: 'float' },
    ],
    objects: object_data,
  })

  click_sort(el, 3)
  assert.ok(_.isEqual(list_items(el, 3), ['10.00', '25.00', '50.00']), 'Sorting by time unit ASC is fine')

  click_sort(el, 3)
  assert.ok(_.isEqual(list_items(el, 3), ['50.00', '25.00', '10.00']), 'Sorting by time unit DESC is fine')
});

QUnit.test('Last column is right-aligned if auto align flag is set', assert => {
  $('#qunit').append('<hr><h1>Last column is right-aligned if auto align flag is set</h1><div id="table-data11"></div>')
  var el = $('#table-data11')

  data = [
    { name: 'some name 1', date_at: new Date() },
    { name: 'some "name" 2', date_at: new Date() },
    { name: 'some name 3', date_at: new Date() },
  ]
  new App.ControllerTable({
    el:       el,
    overview: ['name', 'date_at'],
    attribute_list: [
      { name: 'name', display: 'Name', type: 'text', tag: 'input', translate: true },
      { name: 'date_at', display: 'Date', type: 'text', tag: 'datetime' },
    ],
    autoAlignLastColumn: true,
    objects: data
  });

  assert.equal(el.find('tbody > tr > td:last-child.align-right').length, 3, 'last date column aligned to the right')

  new App.ControllerTable({
    el:       el,
    overview: ['date_at', 'name'],
    attribute_list: [
      { name: 'date_at', display: 'Date', type: 'text', tag: 'datetime' },
      { name: 'name', display: 'Name', type: 'text', tag: 'input', translate: true },
    ],
    autoAlignLastColumn: true,
    objects: data
  });

  assert.equal(el.find('tbody > tr > td.align-right').length, 0, 'last non-date column not aligned to the right')
});

function click_sort(table, column_number) {
  table
    .find(`table > thead > tr > th:nth-child(${column_number}) > .js-sort`)
    .trigger('click')
}

function list_items(table, column_number) {
  return table
    .find(`tbody > tr > td:nth-child(${column_number})`)
    .text()
    .split("\n")
    .filter(elem => elem.match(/[\w]+/))
    .map(elem => elem.trim())
}
