Template.adminProductUsers.helpers

	channels: ->
		ChatRoom.find _id: $in: @channels

	channelIcon: ->
		RocketChat.roomTypes.getIcon @t

	autocompleteSettings: ->
		return {
			limit: 10
			# inputDelay: 300
			rules: [
				{
					collection: ChatRoom
					field: 'name'
					template: Template.roomSearch
					matchAll: true
				}
			]
		}


Template.adminProductUsers.events

	'click .add-channel': (e, instance) ->
		e.preventDefault()
		productId = instance.data._id
		channelName = $('#new-channel-name').val()
		channelId = ChatRoom.findOne(name: channelName)._id
		Meteor.call 'addProductChannel', productId, channelId, (error, result) ->
				if result
					toastr.success t('Product Update Successfully')
				if error
					toastr.error error.reason

	'click .remove-channel': (e, instance) ->
		e.preventDefault()
		productId = instance.data._id
		channelId = $(e.target).data "channelid"
		Meteor.call 'removeProductChannel', productId, channelId, (error, result) ->
				if result
					toastr.success t('Product Update Successfully')
				if error
					toastr.error error.reason

