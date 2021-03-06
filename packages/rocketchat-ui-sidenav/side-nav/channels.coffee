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
		query =
			t: { $in: ['c']},
			open: true

		if !RocketChat.settings.get 'Disable_Favorite_Rooms'
			query.f = { $ne: true }

		if Meteor.user()?.settings?.preferences?.unreadRoomsMode
			query.alert =
				$ne: true

		return ChatSubscription.find query, { sort: 't': 1, 'name': 1 }

Template.channels.events
	'click .add-room': (e, instance) ->
		if RocketChat.authz.hasAtLeastOnePermission('create-c')
			SideNav.setFlex "createChannelFlex"
			SideNav.openFlex()
		else
			e.preventDefault()

	'click .more-channels': ->
		SideNav.setFlex "listChannelsFlex"
		SideNav.openFlex()
