Api = new Restivus
	version: 'v1'
	useDefaultAuth: true
	prettyJson: true

Api.addRoute 'rooms/:id/alert', authRequired: false,
	post: ->
			Meteor.call( 'sendIntegrationMessage', @urlParams.id,
				@bodyParams.msg, @bodyParams.apiKey, { alert: true } )
			status: 'success'
		# try
		# 	Meteor.call( 'sendIntegrationMessage', { key: @bodyParams.apiKey } )
		# 	status: 'success'
		# catch e
		# 	statusCode: e.error
		# 	body: status: 'fail', reason: e.reason
