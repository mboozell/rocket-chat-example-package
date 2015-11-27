Template.adminRoomInfo.helpers
	canDeleteRoom: ->
		return RocketChat.authz.hasAtLeastOnePermission("delete-#{@t}")


Template.adminRoomInfo.events
	'click .delete': ->
		_id = Template.currentData()._id
		swal {
			title: t('Are_you_sure')
			text: t('Delete_Room_Warning')
			type: 'warning'
			showCancelButton: true
			confirmButtonColor: '#DD6B55'
			confirmButtonText: t('Yes_delete_it')
			cancelButtonText: t('Cancel')
			closeOnConfirm: false
			html: false
		}, ->
			swal
				title: t('Deleted')
				text: t('Room_has_been_deleted')
				type: 'success'
				timer: 2000
				showConfirmButton: false

			Meteor.call 'eraseRoom', _id, (error, result) ->
				if error
					toastr.error error.reason
