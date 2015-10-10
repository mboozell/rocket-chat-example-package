Template.hftAlerts.helpers
	images: ->
		images = []
		for id, image of Template.instance().images.get()
			image.id = id
			images.push image
		return images


Template.hftAlerts.onCreated ->
	instance = @
	# @stream = new Meteor.Stream 'hftAlert'
	@images = new ReactiveVar {
		'5min': {
			extension: 'jpg',
			num: 0
		}
	}

	RocketChat.hftAlert.stream.on 'new image', (data) ->
		setTimeout instance.getNewImage.bind(instance, data.id), Math.random()*2000

	@getNewImage = (id) ->
		images = instance.images.get()
		if images[id]
			images[id].num++
			instance.images.set(images)
