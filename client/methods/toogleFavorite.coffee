Meteor.methods
	toogleFavorite: (rid, f) ->
		console.dir rid
		if not Meteor.userId()
			throw new Meteor.Error 203, t('User_logged_out')

		ChatSubscription.update
			rid: rid
			'u._id': Meteor.userId()
		,
			$set:
				f: f

		FinLabs.Analytics.track( 'Toggle Favorite', {
			room: ChatRoom.findOne().name
			toggleOn: f
			})
