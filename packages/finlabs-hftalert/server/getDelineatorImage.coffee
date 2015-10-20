request = Npm.require('request')

FinLabs.hftAlert.getDelineatorImage = (id, callback) ->

	image = FinLabs.hftAlert.settings.images[id]
	if not image
		callback()
	headers =
		"Referer": FinLabs.hftAlert.settings.referer
		"DNT": "1"
	stream = request({url: image.url, headers: headers})
		.pipe(FinLabs.hftAlert.store.upsert(id, image))

	stream.on 'close', (data) ->
		FinLabs.hftAlert.stream.emit 'new image', {id: id}
		callback()

	stream.on 'error', (error) ->
		throw error

	return stream
