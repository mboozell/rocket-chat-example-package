Template.adminRooms.helpers
	isReady: ->
		return Template.instance().ready?.get()
	rooms: ->
		return Template.instance().rooms()
	flexOpened: ->
		return 'opened' if RocketChat.TabBar.isFlexOpen()
	arrowPosition: ->
		return 'left' unless RocketChat.TabBar.isFlexOpen()
	isLoading: ->
		return 'btn-loading' unless Template.instance().ready?.get()
	hasMore: ->
		return Template.instance().limit?.get() is Template.instance().rooms?().count()
	roomCount: ->
		return Template.instance().rooms?().count()
	name: ->
		if @t is 'c' or @t is 'p'
			return @name
		else if @t is 'd'
			return @usernames.join ' x '
	type: ->
		if @t is 'c'
			return TAPi18next.t 'project:Channel'
		else if @t is 'd'
			return TAPi18next.t 'project:Direct Message'
		if @t is 'p'
			return TAPi18next.t 'project:Private Group'
	icon: ->
		return if @t is 'd' then 'at' else if @t is 'p' then 'lock' else 'hash'
	route: ->
		return switch this.t
			when 'd'
				FlowRouter.path('direct', {username: @name})
			when 'p'
				FlowRouter.path('group', {name: @name})
			when 'c'
				FlowRouter.path('channel', {name: @name})

	flexTemplate: ->
		return RocketChat.TabBar.getTemplate()
	flexData: ->
		return RocketChat.TabBar.getData()

Template.adminRooms.onCreated ->
	instance = @
	@limit = new ReactiveVar 50
	@filter = new ReactiveVar ''
	@types = new ReactiveVar []
	@ready = new ReactiveVar true

	@autorun ->
		filter = instance.filter.get()
		types = instance.types.get()
		limit = instance.limit.get()
		subscription = instance.subscribe 'adminRooms', filter, types, limit
		instance.ready.set subscription.ready()

	@autorun ->
		if Session.get 'adminRoomSelected'
			channelSubscription = instance.subscribe 'roomUsers', Session.get 'adminRoomSelected'
			RocketChat.TabBar.setData ChatRoom.findOne Session.get 'adminRoomSelected'
			RocketChat.TabBar.addButton({ id: 'room-info', title: t('Room_Info'), icon: 'icon-info', template: 'adminRoomInfo', order: 1 })
			RocketChat.TabBar.addButton({ id: 'room-users-info', title: t('Room_User_Info'), icon: 'icon-users', template: 'adminRoomUsers', order: 1 })
		else
			RocketChat.TabBar.reset()


	@rooms = ->
		filter = _.trim instance.filter?.get()
		types = instance.types?.get()

		unless _.isArray types
			types = []

		query = {}

		filter = _.trim filter
		if filter
			filterReg = new RegExp filter, "i"
			query = { $or: [ { name: filterReg }, { t: 'd', usernames: filterReg } ] }

		if types.length
			query['t'] = { $in: types }

		return ChatRoom.find(query, { limit: instance.limit?.get(), sort: { name: 1 } })

	@getSearchTypes = ->
		return _.map $('[name=room-type]:checked'), (input) -> return $(input).val()

Template.adminRooms.onRendered ->
	Tracker.afterFlush ->
		SideNav.setFlex "adminFlex"
		SideNav.openFlex()
	instance = Template.instance()
	instance.types.set instance.getSearchTypes()

Template.adminRooms.events
	'keydown #rooms-filter': (e) ->
		if e.which is 13
			e.stopPropagation()
			e.preventDefault()

	'keyup #rooms-filter': (e, t) ->
		e.stopPropagation()
		e.preventDefault()
		t.filter.set e.currentTarget.value

	'click .flex-tab .more': ->
		if RocketChat.TabBar.isFlexOpen()
			RocketChat.TabBar.closeFlex()
		else
			RocketChat.TabBar.openFlex()

	'click .room-info': (e) ->
		e.preventDefault()
		rid = $(e.currentTarget).data('id')
		Session.set 'adminRoomSelected', rid
		Session.set 'showRoomInfo', Meteor.users.findOne(rid)?.name or true
		RocketChat.TabBar.setTemplate 'adminRoomInfo'
		RocketChat.TabBar.openFlex()

	'click .room-info-tabs a': (e) ->
		e.preventDefault()
		$('.info-tabs a').removeClass 'active'
		$(e.currentTarget).addClass 'active'

		$('.user-info-content').hide()
		$($(e.currentTarget).attr('href')).show()

	'click .load-more': (e, t) ->
		e.preventDefault()
		e.stopPropagation()
		t.limit.set t.limit.get() + 50

	'change [name=room-type]': (e, t) ->
		t.types.set t.getSearchTypes()
