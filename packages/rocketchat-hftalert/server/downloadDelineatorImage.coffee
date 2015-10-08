WebApp.connectHandlers.use (req, res, next) ->
	console.log(Meteor.userId)
	re = RocketChat.hftAlert.settings.downloadRoute.exec(req.url)
	if re?
		id = re[1].split('.')[0]
		image = RocketChat.hftAlert.settings.images[id]
		if image
			res.writeHead(200, "Content-Type": "image")
			stream = RocketChat.hftAlert.store.find(id).pipe res
