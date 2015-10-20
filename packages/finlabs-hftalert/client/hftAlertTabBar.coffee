FinLabs.hftAlert.tabBarItem =
	i18nTitle: "rocketchat-hftalert:HFT_Alerts"
	icon: "icon-chart-line"
	id: "hftalert"
	template: "hftAlerts"
	order: 6

Meteor.startup ->
	FinLabs.callbacks.add 'enter-room', ->
		FinLabs.TabBar.addButton FinLabs.hftAlert.tabBarItem
	, FinLabs.callbacks.priority.MEDIUM, 'enter-room-tabbar-hftalert'
