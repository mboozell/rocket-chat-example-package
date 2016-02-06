FinLabs.hftAlert.tabBarItem =
	i18nTitle: "rocketchat-hftalert:HFT_Alerts"
	icon: "icon-chart-line"
	id: "hftalert"
	width: 600
	template: "hftAlerts"
	order: 10
	resizeable: true

Meteor.startup ->
	RocketChat.callbacks.add 'enter-room', ->
		if RocketChat.authz.hasAtLeastOnePermission 'view-hftalerts'
			RocketChat.TabBar.addButton FinLabs.hftAlert.tabBarItem
			, RocketChat.callbacks.priority.MEDIUM, 'enter-room-tabbar-hftalert'

FinLabs.hftAlert.models.Meta = new Meteor.Collection 'rocketchat_hftalert_meta'
