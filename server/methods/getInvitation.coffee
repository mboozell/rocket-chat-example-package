Meteor.methods
	getInvitation: (key) ->

		console.log '[methods] getInvitation -> '.green,' arguments:', arguments

		# create new room
		invitation = RocketChat.models.Invitations.findOneByKey key

		return {
			name: invitation.name
			email: invitation.email
		}
