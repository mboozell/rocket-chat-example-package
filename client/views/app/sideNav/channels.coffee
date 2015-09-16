Template.channels.helpers
	tRoomMembers: ->
		return t('Members_placeholder')

	isAdmin: ->
		return Meteor.user().admin is true

	isActive: ->
		activeChats = ChatSubscription.findOne
			t: {$in: ['c']},
			f: {$ne: true},
			open: true,
			rid: Session.get('openedRoom')
		,
			fields: { _id: 1 }
		return 'active' if activeChats?

	rooms: ->
		subscriptions = ChatSubscription.find
			t: {$in: ['c']},
			f: {$ne: true},
			open: true
		,
			sort: {'t': 1},
			'name': 1
		return subscriptions

Template.channels.events
	'click .add-room': (e, instance) ->
		flexChannel = if Meteor.user().admin is true then "createChannelFlex" else "listChannelsFlex"
		SideNav.setFlex flexChannel
		SideNav.openFlex()

	'click .more-channels': ->
		SideNav.setFlex "listChannelsFlex"
		SideNav.openFlex()
