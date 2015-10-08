request = Npm.require('request')

RocketChat.hftAlerts.getDelineatorImage = (id) ->
	image = RocketChat.hftAlerts.settings.images[id]
	if not image
		return
	headers =
		"Referer": RocketChat.hftAlerts.settings.referer
		"DNT": "1"
	stream = request({url: image.url, headers: headers})
		.pipe(RocketChat.hftAlerts.store.upsert(id, image))

	stream.on 'close', () ->
		console.log('successfully downloaded. refreshing clients')

	return stream
