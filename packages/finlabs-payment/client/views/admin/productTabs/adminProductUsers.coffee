Template.adminProductUsers.helpers

	users: ->
		productId = Template.instance().data._id
		purchases = FinLabs.models.Purchase.find product: productId, active: true
		userIds = purchases.map (product) -> product.user
		Meteor.users.find _id: $in: userIds

	autocompleteSettings: ->
		return {
			limit: 10
			# inputDelay: 300
			rules: [
				{
					collection: Meteor.users
					field: 'username'
					template: Template.userSearch
					matchAll: true
				}
			]
		}


Template.adminProductUsers.events

	'click .add-user': (e, instance) ->
		e.preventDefault()
		productId = instance.data._id
		userName = $('#new-user-name').val()
		userId = Meteor.users.findOne(username: userName)._id
		Meteor.call 'addProductUser', productId, userId, (error, result) ->
				if result
					toastr.success t('Product Update Successfully')
				if error
					toastr.error error.reason

	'click .remove-user': (e, instance) ->
		e.preventDefault()
		productId = instance.data._id
		userId = $(e.target).data "userid"
		Meteor.call 'removeProductUser', productId, userId, (error, result) ->
				if result
					toastr.success t('Product Update Successfully')
				if error
					toastr.error error.reason

