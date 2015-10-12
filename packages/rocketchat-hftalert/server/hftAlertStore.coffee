Grid = Npm.require('gridfs-stream')

do ->
	GridFS = class
		constructor: (name) ->
			mongo = Package.mongo.MongoInternals.NpmModule
			db = Package.mongo.MongoInternals.defaultRemoteCollectionDriver().mongo.db

			@name = name
			@store = new Grid(db, mongo)
			@writing = false

		upsert: (id, image) ->
			stream = @store.createWriteStream
				_id: id
				filename: image.name
				mode: 'w'
				root: @name
				content_type: image.type
			@writing = stream
			stream.on 'close', => @writing = false
			return stream


		find: (id) ->
			@store.createReadStream
				_id: id
				root: @name

	RocketChat.hftAlert.store = new GridFS('rocketchat_plugin_hftalert_files')
