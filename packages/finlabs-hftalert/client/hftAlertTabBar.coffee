FinLabs.hftAlert.tabBarItem =
	i18nTitle: "rocketchat-hftalert:HFT_Alerts"
	icon: "icon-chart-line"
	id: "hftalert"
	width: 600
	template: "hftAlerts"
	order: 6

Meteor.startup ->
	RocketChat.callbacks.add 'enter-room', ->
		RocketChat.TabBar.addButton FinLabs.hftAlert.tabBarItem
	, RocketChat.callbacks.priority.MEDIUM, 'enter-room-tabbar-hftalert'

