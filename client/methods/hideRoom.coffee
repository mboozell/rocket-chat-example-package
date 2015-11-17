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

		rid: Session.get 'currentRoom'

		FinLabs.Analytics.track( 'Hide Room', {
			room: ChatRoom.findOne(rid).name
			username: Meteor.user().name
			roomType: ChatRoom.findOne(rid).t
			users: ChatRoom.findOne(rid).usernames
			})
