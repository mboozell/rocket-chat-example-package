WebApp.connectHandlers.use (req, res, next) ->
	re = FinLabs.hftAlert.settings.downloadRoute.exec(req.url)
	if re?
		id = re[1].split('.')[0]
		image = FinLabs.hftAlert.settings.images[id]
		if image
			imageStream = FinLabs.hftAlert.store.find(id)
				.on('error', ->
					res.writeHead(500)
					res.end()
				)
			if imageStream
				res.writeHead(200, "Content-Type": "image")
				imageStream.pipe res
			else
				res.writeHead(500)
				res.end()
		else
			res.writeHead(404)
			res.end()
	else
		next()
