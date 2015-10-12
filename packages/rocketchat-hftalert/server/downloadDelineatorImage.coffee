WebApp.connectHandlers.use (req, res, next) ->
	re = RocketChat.hftAlert.settings.downloadRoute.exec(req.url)
	if re?
		id = re[1].split('.')[0]
		image = RocketChat.hftAlert.settings.images[id]
		if image
			res.writeHead(200, "Content-Type": "image")
			if RocketChat.hftAlert.store.writing
				console.log("is writing")
				RocketChat.hftAlert.store.writing.on 'close', ->
					console.log("writing ended")
					RocketChat.hftAlert.store.find(id).pipe res
			else
				console.log("not writing")
				RocketChat.hftAlert.store.find(id).pipe res
			return
	else
		next()
