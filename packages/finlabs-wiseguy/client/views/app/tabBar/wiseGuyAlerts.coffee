Template.wiseGuyAlerts.helpers
	alerts: ->
		return Template.instance().WiseGuyAlerts()

Template.wiseGuyAlerts.onCreated ->
	instance = @
	@ready = new ReactiveVar true

	@autorun ->
		subscription = instance.subscribe 'wiseGuyAlerts', 20
		instance.ready.set subscription.ready()

	@alerts = ->
		return Meteor.WiseGuyAlerts.find({}).fetch()

Template.wiseGuyAlerts.onRendered ->
