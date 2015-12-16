Template.adminProductInfo.helpers {}


Template.adminProductInfo.events

	'click .save': (e, instance) ->
		e.preventDefault()
		productId = instance.data._id
		isBaseProduct = $('input[name="isBaseProduct"]').is(':checked')
		Meteor.call 'updateProductBaseStatus', productId, isBaseProduct, (error, result) ->
				if result
					toastr.success t('Product Update Successfully')
				if error
					toastr.error error.reason
