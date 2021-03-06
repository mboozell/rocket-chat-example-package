Meteor.methods
	deleteUser: (userId) ->
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] deleteUser -> Invalid user")

		user = RocketChat.models.Users.findOneById Meteor.userId()

		unless RocketChat.authz.hasPermission(Meteor.userId(), 'delete-user') is true
			throw new Meteor.Error 'not-authorized', '[methods] deleteUser -> Not authorized'

		user = RocketChat.models.Users.findOneById userId
		unless user?
			throw new Meteor.Error 'not-found', '[methods] deleteUser -> User not found'

		RocketChat.models.Messages.removeByUserId userId # Remove user messages

		RocketChat.models.Subscriptions.findByUserId(userId).forEach (subscription) ->
			room = RocketChat.models.Rooms.findOneById subscription.rid
			if room.t isnt 'c' and room.usernames.length is 1
				RocketChat.models.Rooms.removeById subscription.rid # Remove non-channel rooms with only 1 user (the one being deleted)
			if room.t is 'd'
				RocketChat.models.Subscriptions.removeByRoomId subscription.rid
				RocketChat.models.Messages.removeByRoomId subscription.rid


		RocketChat.models.Subscriptions.removeByUserId userId # Remove user subscriptions
		RocketChat.models.Rooms.removeByTypeContainingUsername 'd', user.username # Remove direct rooms with the user
		RocketChat.models.Rooms.removeUsernameFromAll user.username # Remove user from all other rooms
		RocketChat.models.Users.removeById userId # Remove user from users database

		# Purchase Stuff
		FinLabs?.models?.Transaction?.removeByUser user._id
		FinLabs?.models?.Customer?.removeByUser user._id
		FinLabs?.models?.Purchase?.removeByUser user._id
		FinLabs?.models?.Subscription?.removeByUser user._id

		return true
