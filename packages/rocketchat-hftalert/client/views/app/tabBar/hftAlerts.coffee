Template.hftAlerts.helpers
	images: ->
		images = []
		for id, image of Template.instance().images.get()
			image.id = id
			images.push image
		return images


Template.hftAlerts.onCreated ->
	instance = @
	@stream = new Meteor.Stream 'hftAlert'
	@images = new ReactiveVar {
		'5min': {
			extension: 'jpg',
			num: 0
		}
	}

	@stream.on 'new image', (data) ->
		images = instance.images.get()
		if images[data.id]
			images[data.id].num++
			instance.images.set(images)
