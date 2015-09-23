Template.adminRoomUsers.helpers

	isModerator: ->
		rid = Template.currentData()._id
		RocketChat.authz.hasRole(@_id, 'moderator', rid)

	users: ->
		console.log(@)
		Meteor.users.find({}, { limit: 0, sort: { username: 1, name: 1 } }).fetch()

Template.adminRoomUsers.events

	'click .user-info': (e) ->
		e.preventDefault()
		rid = Template.currentData()._id
		user = $(e.currentTarget).data('id')
		Meteor.call 'setModeratorStatus', user, rid
