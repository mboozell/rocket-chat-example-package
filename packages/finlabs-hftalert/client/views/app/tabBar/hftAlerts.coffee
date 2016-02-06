Template.hftAlerts.helpers
	images: ->
		images = []
		for id, image of Template.instance().images.get()
			image.id = id
			images.push image
		return images

	getUrl: ->
		{host, protocol} = window.location
		base = "/plugins/hftalert/image/"
		image = "#{@id}.#{@extension}?num=#{@num}"
		return protocol + '//' + host + base + image


Template.hftAlerts.onCreated ->
	instance = @
	@ready = new ReactiveVar false
	@images = new ReactiveVar
		'30min':
			caption: "Delineator"
			extension: "jpg"
			num: 0
		'SPYLiquidity':
			caption: "SPY Liquidity",
			extension: 'jpg',
			num: 0
		'SPYPressure':
			caption: "SPY Market Pressure",
			extension: 'jpg',
			num: 0
		'VXXPressure':
			caption: "VXX Market Pressure",
			extension: 'jpg',
			num: 0

	imagesToWatch = []
	imagesToWatch.push image for image of @images.get()

	@autorun =>
		sub = @subscribe 'hftalertMeta', imagesToWatch
		if sub.ready()
			@ready.set true

	@getNewImage = (id) ->
		setTimeout ->
			images = instance.images.get()
			if images[id]
				images[id].num++
				instance.images.set(images)
		, Math.round Math.random() * 2000

	FinLabs.hftAlert.models.Meta.find().observe
		changed: (image) ->
			unless image.locked
				instance.getNewImage image._id

Template.hftAlerts.onRendered ->
	$('.hft-alert-swipebox').swipebox()
