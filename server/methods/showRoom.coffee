Meteor.methods
	showRoom: (rid) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', '[methods] showRoom -> Invalid user'

		console.log '[methods] showRoom -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments
		console.log ChatSubscription.findOne
			rid: rid
			'u._id': Meteor.userId()

		ChatSubscription.update
			rid: rid
			'u._id': Meteor.userId()
		,
			$set:
				open: true

		console.log ChatSubscription.findOne
			rid: rid
			'u._id': Meteor.userId()
