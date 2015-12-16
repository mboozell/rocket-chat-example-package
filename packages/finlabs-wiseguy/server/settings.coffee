
Meteor.startup ->

  permissions = [

    { _id: 'view-wiseguy-alerts',
    roles : ['admin', 'moderator', 'wsj-user']}

  ]

  #alanning:roles
  roles = _.pluck(Roles.getAllRoles().fetch(), 'name')

  for permission in permissions
    RocketChat.models.Permissions.upsert( permission._id, {$setOnInsert : permission })
    for role in permission.roles
      unless role in roles
        Roles.createRole role
        roles.push(role)

	FinLabs.payment?.tools.add "wiseguy-alerts", ['wsj-user']
