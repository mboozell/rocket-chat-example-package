Api = new Restivus
	version: 'v1'
	useDefaultAuth: true
	prettyJson: true


Api.addRoute 'rooms/:id/send', authRequired: true,
	post: ->
		Meteor.runAsUser this.userId, () =>
			console.log @bodyParams.msg
			Meteor.call('sendMessage', {msg: this.bodyParams.msg, rid: @urlParams.id} )
		status: 'success'	#need to handle error
