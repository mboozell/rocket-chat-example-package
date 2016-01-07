Meteor.methods
	sendMessage: (message) ->
		if not Meteor.userId()
			throw new Meteor.Error 203, t('User_logged_out')

		if _.trim(message.msg) isnt ''

			message.ts = new Date(Date.now() + TimeSync.serverOffset())

			message.u =
				_id: Meteor.userId()
				username: Meteor.user().username

			message.temp = true

			message = RocketChat.callbacks.run 'beforeSaveMessage', message

			rid = Session.get 'openedRoom'

			ChatMessage.insert message

			FinLabs?.Analytics?.track('Sent Message', {
				username: Meteor.user().name
				room: ChatRoom.findOne(rid).name
				roomType: ChatRoom.findOne(rid).t
				users: ChatRoom.findOne(rid).usernames
				})
