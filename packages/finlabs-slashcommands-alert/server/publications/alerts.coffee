Meteor.publish 'slashcommand_alert', (ts) ->
	unless this.userId
		return this.ready()

	subscriptions = RocketChat.models.Subscriptions.findByUserId this.userId
	console.log subscriptions

	return FinLabs.slashAlert.models.Alert.findAfterTime ts
