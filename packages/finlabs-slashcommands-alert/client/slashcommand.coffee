RocketChat.slashCommands.add 'alert', undefined,
	description: TAPi18n.__ 'Alert_channel_of_important_information'
	params: 'optional message'
	filter: () ->
		roomId = Session.get "openedRoom"
		return RocketChat.authz.hasAtLeastOnePermission 'alert-room', roomId

FinLabs.slashAlert.models.Alert = new Meteor.Collection "rocketchat_slashcommand_alert"

document.addEventListener 'DOMContentLoaded', ->
	Blaze.render Template.slashAlertActivator, document.body
, false
