Api = new Restivus
	version: 'v1'
	useDefaultAuth: true
	prettyJson: true

Api.addRoute 'rooms/:id/alert', authRequired: false,
	post: ->
		try
			message = { rid: @urlParams.id, msg: @bodyParams.msg, alert: true}
			Meteor.call 'sendIntegrationMessage', message, @bodyParams.apiKey
			status: 'success'
		catch e
			statusCode: e.error
			body: status: 'fail', reason: e.reason
