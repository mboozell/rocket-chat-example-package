Meteor.methods
	leaveRoom: (rid) ->
		if not Meteor.userId()
			throw new Meteor.Error 203, t('User_logged_out')

		ChatSubscription.remove
			rid: rid
			'u._id': Meteor.userId()

		ChatRoom.update rid,
			$pull:
				usernames: Meteor.user().username

		FinLabs?.Analytics?.track( 'Leave Room', {
			room: ChatRoom.findOne(rid).name
			username: Meteor.user().name
			roomType: ChatRoom.findOne(rid).t
			})
