Api = new Restivus
	version: 'v1'
	useDefaultAuth: true
	prettyJson: true

Api.addRoute 'rooms/:id/alert', authRequired: false,
	post: ->
		try
			Meteor.call('sendIntegrationMessage', { rid: @urlParams.id, msg: @bodyParams.msg, alert: true},
				@bodyParams.apiKey)
			status: 'success'
		catch e
			statusCode: e.error
			body: status: 'fail', reason: e.reason
