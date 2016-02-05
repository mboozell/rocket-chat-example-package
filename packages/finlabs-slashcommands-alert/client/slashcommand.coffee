RocketChat.slashCommands.add 'alert', undefined,
	description: TAPi18n.__ 'Alert_channel_of_important_information'
	params: 'optional message'
	filter: () ->
		roomId = Session.get "openedRoom"
		return RocketChat.authz.hasAtLeastOnePermission 'alert-room', roomId

# FinLabs.slashAlert.stream.on 'new-alert', (data) ->
# 	if Meteor.userId() == data.user
# 		return
# 	if ChatSubscription.findOne({rid: data.room, open: true})
# 		if Meteor.user().status in ["online", "away"]
# 			bell = $('#marketOpenCloseNotification')
# 			if bell.length > 0
# 				bell[0].play()

document.addEventListener 'DOMContentLoaded', ->
	Blaze.render Template.slashAlertActivator, document.body
, false
