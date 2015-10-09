Template.hftAlerts.helpers
	images: ->
		images = []
		for id, image of Template.instance().images
			image.id = id
			images.push image
		return images


Template.hftAlerts.onCreated ->
	instance = @
	@stream = new Meteor.Stream 'hftAlert'
	@images = {
		'5min': {
			extension: 'jpg',
			num: 0
		}
	}

	@stream.on 'new image', (data) ->
		instance.images[data.id]?.num++
