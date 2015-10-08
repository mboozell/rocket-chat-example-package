Api = new Restivus
	useDefaultAuth: true
	prettyJson: true

Api.addRoute 'test', authRequired: false,
	get: ->
		RocketChat.hftAlerts.getDelineatorImage '5min'
		status: 'cool'
