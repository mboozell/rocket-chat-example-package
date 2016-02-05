Meteor.startup ->

	# Note:
	# 1.if we need to create a role that can only edit channel message, but not edit group message
	# then we can define edit-<type>-message instead of edit-message
	# 2. admin, moderator, and user roles should not be deleted as they are referened in the code.
	permissions = [

		{ _id: 'alert-room',
		roles : ['admin', 'moderator']}

	]

	#alanning:roles
	roles = _.pluck(Roles.getAllRoles().fetch(), 'name')

	for permission in permissions
		RocketChat.models.Permissions.upsert( permission._id, {$set: permission })
		for role in permission.roles
			unless role in roles
				Roles.createRole role
				roles.push(role)
