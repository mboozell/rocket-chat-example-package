Meteor.methods
	getInvitation: (key) ->

		console.log '[methods] getInvitation -> '.green,' arguments:', arguments

		# create new room
		invitation = RocketChat.models.Invitations.findOneByKey key

		return if invitation then {
			name: invitation.name
			email: invitation.email
		} else {}
