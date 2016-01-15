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
			setLocked = Meteor.bindEnvironment FinLabs.hftAlert.models.Meta.setLocked.bind(FinLabs.hftAlert.models.Meta)
			setLocked id, true
			stream = @store.createWriteStream
				_id: id
				filename: image.name
				mode: 'w'
				root: @name
				content_type: image.type
			stream.on 'close', => setLocked id, false
			return stream

		find: (id) ->
			tries = 0
			while not FinLabs.hftAlert.models.Meta.isLocked(id)
				if ++tries > 3
					return null
				Meteor.wrapAsync(Meteor.setTimeout, Meteor)(->
					return null
				, 100)
			@store.createReadStream
				_id: id
				root: @name

		exists: (id) ->
			exists = Meteor.wrapAsync @store.exist, @store
			return exists _id: id

	FinLabs.hftAlert.store = new GridFS 'rocketchat_hftalert_files'
