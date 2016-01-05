Api = new Restivus
	version: 'v1'
	useDefaultAuth: true

Api.addRoute 'plugins/wiseguy/alert', authRequired: false,
	post: ->
		return status: 'success'
	# 	console.log "route reached"
	# 	try
	# 		console.log "SAVING WISE GUY"
	# 		# FinLabs.WiseGuy.saveAlert @bodyParams.data, @bodyParams.apiKey
	# 		status: 'success'
	# 	catch e
	# 		console.log e
	# 		statusCode: e.error
	# 		body: satus: 'fail', reason: e.reason
