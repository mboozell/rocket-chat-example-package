# Config and Start SyncedCron
SyncedCron.config
	collectionName: 'rocketchat_cron_history'

Meteor.startup ->
	Meteor.defer ->

		for id, image of RocketChat.hftAlert.settings.images
			SyncedCron.add
				name: "Get Delineator Image [#{id}]",
				schedule: (parser) -># parser is a later.parse object
					return parser.text image.frequency
				job: ->
					try
						RocketChat.hftAlert.getDelineatorImage id
					return true
