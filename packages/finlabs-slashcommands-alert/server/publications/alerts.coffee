Meteor.publish 'slashcommandAlert', (limit, sort) ->
	unless this.userId
		return this.ready()

	subscriptions = RocketChat.models.Subscriptions.findByUserId this.userId
	rids = subscriptions.map (sub) -> sub.rid

	result = FinLabs.slashAlert.models.Alert.findInRoomsNotFromUser rids, this.userId,
		limit: limit
		sort: sort

	return result
