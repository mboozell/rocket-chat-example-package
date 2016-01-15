WebApp.connectHandlers.use (req, res, next) ->
	error = ->
		unless res.headersSent
			res.writeHead(500)
		res.end()

	re = FinLabs.hftAlert.settings.downloadRoute.exec(req.url)
	if re?
		id = re[1].split('.')[0]
		image = FinLabs.hftAlert.settings.images[id]
		if image
			imageStream = FinLabs.hftAlert.store.find(id)
				.on('error', error)
			if imageStream
				res.writeHead(200, "Content-Type": "image")
				imageStream.pipe(res).on('error', error)
			else
				error()
		else
			error()
	else
		next()
