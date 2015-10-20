request = Npm.require('request')

RocketChat.hftAlert.getDelineatorImage = (id, callback) ->

	image = RocketChat.hftAlert.settings.images[id]
	if not image
		callback()
	headers =
		"Referer": RocketChat.hftAlert.settings.referer
		"DNT": "1"
	stream = request({url: image.url, headers: headers})
		.pipe(RocketChat.hftAlert.store.upsert(id, image))

	stream.on 'close', (data) ->
		RocketChat.hftAlert.stream.emit 'new image', {id: id}
		callback()

	stream.on 'error', (error) ->
		throw error

	return stream
