Meteor.methods
	setUserActiveStatus: (userId, active) ->
		FinLabs?.Analytics?.track 'Set Active Status'
		Meteor.users.update userId, { $set: { active: active } }
		return true
