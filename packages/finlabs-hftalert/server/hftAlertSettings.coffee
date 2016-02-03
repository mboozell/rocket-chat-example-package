FinLabs.hftAlert.settings =
	downloadRoute: /^\/plugins\/hftalert\/image\/(.*)$/
	referer: "http://www.sghammer.com/users/journal/index.html"
	images:
		'5min':
			name: "5min.jpg"
			url: "http://www.hcmi.com/users/subscribers/Advanced/5min/Delin_ny.jpg"
			type: "image/jpg"
			frequency: "every 1 min"
		'30min':
			name: "30min.jpg"
			url: "http://www.hcmi.com/users/subscribers/Advanced/30min/Delin_ny.jpg"
			type: "image/jpg"
			frequency: "every 30 sec"
		'daily':
			name: "daily.jpg"
			url: "http://www.hcmi.com/users/subscribers/Advanced/30min/daily.jpg"
			type: "image/jpg"
			frequency: "every 1 hour"
		'SPYLiquidity':
			name: "SPYLiquidity.jpg"
			url: "http://www.hcmi.com/users/subscribers/Advanced/accums2/1min/accum_SPY_4.jpg"
			type: "image/jpg"
			frequency: "every 30 sec"
		'SPYPressure':
			name: "SPYPressure.jpg"
			url: "http://www.hcmi.com/users/subscribers/Advanced/accums2/1min/accum_SPY.jpg"
			type: "image/jpg"
			frequency: "every 30 sec"
		'VXXPressure':
			name: "VXXPressure.jpg"
			url: "http://www.hcmi.com/users/subscribers/Advanced/1min/accum_VXX.jpg"
			type: "image/jpg"
			frequency: "every 30 sec"

FinLabs.hftAlert.stream.permissions.write -> false
FinLabs.hftAlert.stream.permissions.read -> true

for id, image of FinLabs.hftAlert.settings.images
	FinLabs.hftAlert.models.Meta.create id


Meteor.startup ->

  permissions = [

    { _id: 'view-hftalerts',
    roles : ['admin', 'moderator', 'hftalert-user']}

  ]

  #alanning:roles
  roles = _.pluck(Roles.getAllRoles().fetch(), 'name')

  for permission in permissions
    RocketChat.models.Permissions.upsert( permission._id, {$setOnInsert : permission })
    for role in permission.roles
      unless role in roles
        Roles.createRole role
        roles.push(role)

	FinLabs.payment?.tools.add "hftalerts", ['hftalert-user']

