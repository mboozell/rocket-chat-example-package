request = Npm.require('request')

FinLabs.hftAlert.getDelineatorImage = (id, callback) ->

	image = FinLabs.hftAlert.settings.images[id]
	if not image
		return callback({message: "No Image"})

	headers =
		"Referer": FinLabs.hftAlert.settings.referer
		"DNT": "1"

	emitStream = ->
		FinLabs.hftAlert.stream.emit 'new image', {id: id}
		callback()

	stream = request({url: image.url, headers: headers})
		.on('error', callback)
		.pipe(FinLabs.hftAlert.store.upsert(id, image))
		.on('close', emitStream)
		.on('error', callback)

	return stream
