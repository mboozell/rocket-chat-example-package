Meteor.publish 'hftalertMeta', (ids) ->
	unless this.userId
		return this.ready()

	unless RocketChat.authz.hasPermission this.userId, 'view-hftalerts'
		return this.ready()

	FinLabs.hftAlert.models.Meta.findByIds ids

