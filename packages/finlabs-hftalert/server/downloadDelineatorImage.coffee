WebApp.connectHandlers.use (req, res, next) ->
	re = FinLabs.hftAlert.settings.downloadRoute.exec(req.url)
	if re?
		id = re[1].split('.')[0]
		image = FinLabs.hftAlert.settings.images[id]
		if image
			res.writeHead(200, "Content-Type": "image")
			if FinLabs.hftAlert.store.writing
				FinLabs.hftAlert.store.writing.on 'close', ->
					FinLabs.hftAlert.store.find(id).pipe res
			else
				FinLabs.hftAlert.store.find(id).pipe res
			return
	else
		next()
