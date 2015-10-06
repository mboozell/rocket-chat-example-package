Meteor.publish 'integrations', ->
	unless this.userId
		return this.ready()

	if RocketChat.authz.hasPermission( @userId, 'view-integrations') isnt true
		return this.ready()

	console.log '[publish] integrations'.green

	RocketChat.models.Integrations.find()
