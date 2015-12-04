Template.adminProductChannels.helpers

	channels: ->
		ChatRoom.find _id: $in: @channels

	channelIcon: ->
		RocketChat.roomTypes.getIcon @t


Template.adminProductChannels.events

	'click .add-channel': (e, instance) ->
		e.preventDefault()
		productId = instance.data._id
		isBaseProduct = $('input[name="isBaseProduct"]').is(':checked')
		Meteor.call 'updateProductBaseStatus', productId, isBaseProduct, (error, result) ->
				if result
					toastr.success t('Product Update Successfully')
				if error
					toastr.error error.reason

	'click .remove-channel': (e, instance) ->
		e.preventDefault()
		productId = instance.data._id
