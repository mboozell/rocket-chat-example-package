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
	@stream = new Meteor.Stream 'hftAlert'
	@images = new ReactiveVar
		'5min':
			caption: "5 minute",
			extension: 'jpg',
			num: 0

	RocketChat.hftAlert.stream.on 'new image', (data) ->
		setTimeout instance.getNewImage.bind(instance, data.id), Math.random()*2000

	@getNewImage = (id) ->
		images = instance.images.get()
		if images[id]
			images[id].num++
			instance.images.set(images)

Template.hftAlerts.onRendered ->
	$('.hft-alert-swipebox').swipebox()
