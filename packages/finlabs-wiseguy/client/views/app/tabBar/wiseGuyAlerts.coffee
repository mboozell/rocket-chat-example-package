Template.wiseGuyAlerts.helpers
	alerts: ->
		return Template.instance().alerts()

	timestamp: ->
		return this.ts.toTimeString().substr(0,5)

	getState: ->
		if this.state is 1 then 'bullish' else 'bearish'

Template.wiseGuyAlerts.onCreated ->
	instance = @
	@ready = new ReactiveVar true

	@autorun ->
		subscription = instance.subscribe 'wiseGuyAlerts', 20
		instance.ready.set subscription.ready()

	@alerts = ->
		return WiseGuyAlerts.find({}).fetch()

Template.wiseGuyAlerts.onRendered ->
