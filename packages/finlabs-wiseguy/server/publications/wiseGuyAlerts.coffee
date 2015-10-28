Meteor.publish 'wiseGuyAlerts', (limit) ->
	unless @userId and RocketChat.authz.hasPermission @userId, 'view-wiseguy-alerts' is true
		return @ready()

  FinLabs.models.WiseGuyAlerts.find {},
    limit: limit,
    sort: ts: 1
