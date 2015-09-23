Meteor.publish 'roomUsers', (rid, limit) ->
	unless @userId
		return @ready()

	user = Meteor.users.findOne @userId

	fields =
		name: 1
		username: 1
		status: 1
		utcOffset: 1

	if RocketChat.authz.hasPermission( @userId, 'view-full-other-user-info') is true
		fields = _.extend fields,
			emails: 1
			phone: 1
			statusConnection: 1
			createdAt: 1
			lastLogin: 1
			active: 1
			services: 1
			roles : 1

	query = username: $in: ChatRoom.findOne(rid).usernames

	console.log '[publish] roomUsers'.green, rid, limit

	Meteor.users.find query,
		fields: fields
		limit: limit
		sort: { username: 1 }
