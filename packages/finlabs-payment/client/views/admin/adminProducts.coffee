Template.adminProducts.helpers

	isReady: ->
		return Template.instance().ready.get()
	products: ->
		console.log Template.instance().products()
		return Template.instance().products()

Template.adminProducts.onCreated ->
	instance = @
	@ready = new ReactiveVar false

	@autorun ->
		subscription = instance.subscribe 'products'
		instance.ready.set subscription.ready()

	@products = ->
		Products.find()

Template.adminProducts.events
	'click .submit .button': (e, instance) ->
		form = $('input[name="product_name"]')
		name = form.val()
		Meteor.call 'createProduct', name, (error, result) ->
			if result
				form.val('')
			if error
				toastr.error error.reason
