Meteor.methods
	setModeratorStatus: (userId, rid, moderator) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] setAdminStatus -> Invalid user"

		unless RocketChat.authz.hasPermission( Meteor.userId(), 'assign-moderator-role') is true
			throw new Meteor.Error 'not-authorized', '[methods] setAdminStatus -> Not authorized'

		if moderator is undefined
			moderator = !RocketChat.authz.hasRole(userId, 'moderator', rid)
		if moderator
			RocketChat.authz.addUsersToRoles( userId, 'moderator', rid )
		else
			RocketChat.authz.removeUsersFromRoles( userId, 'moderator', rid )

		return true
