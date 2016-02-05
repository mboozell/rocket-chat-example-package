Template.slashAlertActivator.helpers {}

Template.slashAlertActivator.onCreated ->
	instance = @
	@ready = new ReactiveVar false

	@autorun =>
		sub = @subscribe 'slashcommandAlert', 1, ts: -1
		if sub.ready()
			@ready.set true

Template.slashAlertActivator.onRendered ->

	playBell = ->
		bell = $('#marketOpenCloseNotification')
		if bell.length > 0
			bell[0].play()

	alertBell = ((startTime) -> (alert) ->
		if alert.ts > startTime
			console.log alert
			if Meteor.user().status in ["online", "away"]
				playBell()
	)(new Date())

	FinLabs.slashAlert.models.Alert.find().observe
		added: alertBell
