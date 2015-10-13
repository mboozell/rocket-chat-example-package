Api = new Restivus
	useDefaultAuth: true
	prettyJson: true

# join a room
Api.addRoute 'invitation/test', authRequired: true,
	post: ->
		Meteor.runAsUser this.userId, () =>
			Meteor.call 'createInvitation', @bodyParams.email, @bodyParams.name
		status: 'success'
