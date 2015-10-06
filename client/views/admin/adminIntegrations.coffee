Template.adminIntegrations.helpers
	isReady: ->
		return Template.instance().ready.get()
	integrations: ->
		return Template.instance().integrations()

Template.adminIntegrations.onCreated ->
	instance = @
	@ready = new ReactiveVar false

	@autorun ->
		subscription = instance.subscribe 'integrations'
		instance.ready.set subscription.ready()

	@integrations = ->
		Integrations.find()

Template.adminIntegrations.events
	'click .submit .button': (e, instance) ->
		console.log(instance.integrations())
		form = $('input[name="integration_name"]')
		name = form.val()
		Meteor.call 'createIntegration', name, (error, result) ->
			if result
				form.val('')
			if error
				toastr.error error.reason
