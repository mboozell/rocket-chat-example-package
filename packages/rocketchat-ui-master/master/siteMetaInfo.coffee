Template.siteMetaInfo.helpers

	hostname: ->
		Session.get 'hostname'

Template.siteMetaInfo.onCreated ->

	Meteor.call 'getHostname', (err, hostname) ->
		unless err
			Session.set 'hostname', hostname

