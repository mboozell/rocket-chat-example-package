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

		FinLabs?.Analytics?.track( 'Toggle Favorite', {
			room: ChatRoom.findOne(rid).name
			toggleOn: f
			roomType: ChatRoom.findOne(rid).t
			username: Meteor.user().username
			users: ChatRoom.findOne(rid).usernames
			})
