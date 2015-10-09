Meteor.startup ->
	Meteor.defer ->

		getImage = Meteor.wrapAsync RocketChat.hftAlert.getDelineatorImage, RocketChat.hftAlert

		for id, image of RocketChat.hftAlert.settings.images
			do (id, image) ->
				SyncedCron.add
					name: "Get Delineator Image [#{id}]",
					schedule: (parser) -> # parser is a later.parse object
						return parser.text image.frequency
					job: ->
						for tries in [1..3]
							try
								getImage id
								console.log('Downloaded Successfully!')
								break
							catch e
								console.log('Couldnt download. Trying again')
								continue
						return true
