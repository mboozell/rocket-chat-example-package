@burger =
	menuClosed: ->
		return $('.menu-nav').hasClass('menu-closed')

Template.burger.helpers
	unread: ->
		return Session.get 'unread'

	menuClosed: ->
		return Session.get 'menuClosed'
