request = Npm.require('request')

RocketChat.hftAlert.getDelineatorImage = (id) ->

	image = RocketChat.hftAlert.settings.images[id]
	if not image
		return
	headers =
		"Referer": RocketChat.hftAlert.settings.referer
		"DNT": "1"
	stream = request({url: image.url, headers: headers})
		.pipe(RocketChat.hftAlert.store.upsert(id, image))

	stream.on 'close', () ->
		console.log('successfully downloaded. refreshing clients')

	return stream
