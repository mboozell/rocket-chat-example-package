Meteor.methods
	hideRoom: (rid) ->
		if not Meteor.userId()
			throw new Meteor.Error 203, t('User_logged_out')

		ChatSubscription.update
			rid: rid
			'u._id': Meteor.userId()
		,
			$set:
				alert: false
				open: false

		FinLabs.Analytics.track( 'Hide Room', {
			roomId: rid
			username: Meteor.users.findOne(this.userId).username
			})
