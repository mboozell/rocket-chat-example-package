Api = new Restivus
	version: 'v1'
	useDefaultAuth: true
	prettyJson: true

Api.addRoute 'plugins/wiseguy/alert', authRequired: false,
	post: ->
		try
			FinLabs.WiseGuy.saveAlert @bodyParams.data, @bodyParams.apiKey
			status: 'success'
		catch e
			console.log e
			statusCode: e.error
			body: satus: 'fail', reason: e.reason
