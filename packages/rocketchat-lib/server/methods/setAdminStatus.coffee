Meteor.methods
	setAdminStatus: (userId, admin) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] setAdminStatus -> Invalid user"

		unless RocketChat.authz.hasPermission( Meteor.userId(), 'assign-admin-role') is true
			throw new Meteor.Error 'not-authorized', '[methods] setAdminStatus -> Not authorized'

		if admin is undefined
			admin = !RocketChat.authz.hasPermission(userId, 'admin')
		if admin
			RocketChat.authz.addUsersToRoles( userId, 'admin')
		else
			RocketChat.authz.removeUsersFromRoles( userId, 'admin')

		RocketChat.callbacks.run 'afterAdminStatusSet', userId, admin

		return true
