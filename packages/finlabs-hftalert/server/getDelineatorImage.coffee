request = Npm.require('request')

FinLabs.hftAlert.getDelineatorImage = (id, callback) ->

	image = FinLabs.hftAlert.settings.images[id]
	if not image
		return callback({message: "No Image"})

	headers =
		"Referer": FinLabs.hftAlert.settings.referer
		"DNT": "1"

	finish = -> callback()

	stream = request({url: image.url, headers: headers})
		.on('error', callback)
		.pipe(FinLabs.hftAlert.store.upsert(id, image))
		.on('close', finish)
		.on('error', callback)

	return stream
