Meteor.methods
	setUserActiveStatus: (userId, active) ->
		Meteor.users.update userId, { $set: { active: active } }
		return true

		FinLabs.Analytics.track( 'Set Active Status', {
			username: Meteor.users.findOne(this.userId).username
			})
