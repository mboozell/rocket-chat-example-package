Template.adminRoomUserInfo.helpers

	users: ->
		Meteor.users.find({}, { limit: 0, sort: { username: 1, name: 1 } }).fetch()
