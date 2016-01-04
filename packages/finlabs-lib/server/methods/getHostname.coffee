hostname = Npm.require('os').hostname()

Meteor.methods
	getHostname: () ->
		return hostname
