Meteor.methods
	deleteMessage: (message) ->
		if not Meteor.userId()
			throw new Meteor.Error 203, t('general.User_logged_out')

		hasPermission = RocketChat.authz.hasAtLeastOnePermission('delete-message', message.rid)
		deleteAllowed = RocketChat.settings.get 'Message_AllowDeleting'
		deleteOwn = message?.u?._id is Meteor.userId()

		unless hasPermission or (deleteAllowed and deleteOwn)
			throw new Meteor.Error 'message-deleting-not-allowed', t('Message_deleting_not_allowed')

		Tracker.nonreactive ->
			ChatMessage.remove
				_id: message._id
				'u._id': Meteor.userId()

		rid = Session.get 'openedRoom'

		FinLabs?.Analytics?.track( 'Delete Message', {
			username: Meteor.user().name
			room: ChatRoom.findOne(rid).name
			roomType: ChatRoom.findOne(rid).t
			users: ChatRoom.findOne(rid).usernames
			})
