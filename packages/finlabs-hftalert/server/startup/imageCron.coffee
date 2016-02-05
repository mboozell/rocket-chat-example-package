Meteor.startup ->
	Meteor.defer ->

		getImage = Meteor.wrapAsync FinLabs.hftAlert.getDelineatorImage, FinLabs.hftAlert
		debug = RocketChat.settings.get("Debug_Level") == "debug"

		for id, image of FinLabs.hftAlert.settings.images
			do (id, image) ->
				SyncedCron.add
					name: "Get Delineator Image [#{id}]",
					schedule: (parser) -> # parser is a later.parse object
						return parser.text "#{image.frequency} every weekday after 9:00 am before 4:30 pm"
					job: ->
						for tries in [1..3]
							try
								getImage id
								if debug then console.log("#{id} Downloaded Successfully!")
								break
							catch e
								if debug
									console.log("#{id} Couldn't download. Trying again")
									console.log(e.message)
								continue
						return true

		SyncedCron.config
			log: debug

