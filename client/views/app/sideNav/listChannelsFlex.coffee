Template.listChannelsFlex.helpers
	channel: ->
		return Template.instance().channelsList?.get()


Template.listChannelsFlex.events
	'click header': ->
		SideNav.closeFlex()

	'click .channel-link': (e) ->
		rid = e.target.getAttribute 'data-room'
		Meteor.call 'showRoom', rid
		SideNav.closeFlex()

	'click footer .create': ->
		if RocketChat.authz.hasAtLeastOnePermission( 'create-c')
			SideNav.setFlex "createChannelFlex"

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

Template.listChannelsFlex.onCreated ->
	instance = this
	instance.channelsList = new ReactiveVar []

	Meteor.call 'channelsList', (err, result) ->
		if result
			instance.channelsList.set result.channels
