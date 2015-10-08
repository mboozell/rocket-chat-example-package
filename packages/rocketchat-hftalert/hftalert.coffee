Grid = Npm.require('gridfs-stream')

RocketChat.hftAlerts = {}

do ->
	GridFS = class
		constructor: (name) ->
			mongo = Package.mongo.MongoInternals.NpmModule
			db = Package.mongo.MongoInternals.defaultRemoteCollectionDriver().mongo.db

			this.name = name
			this.store = new Grid(db, mongo)

		upsert: (id, image) ->
			this.store.createWriteStream
				_id: id
				filename: image.name
				mode: 'w'
				root: this.name
				content_type: image.type


		find: (id) ->
			this.store.createReadStream
				_id: id
				root: this.name


	RocketChat.hftAlerts.store = new GridFS('rocketchat_plugin_hftalert_files')
