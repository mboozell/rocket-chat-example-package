Meteor.startup(function() {
	var settings = {
		i18nTitle: "Example",
		icon: "icon-example",
		id: "example",
		template: "examplePackageMain",
		order: 10,
	};
	return RocketChat.callbacks.add('enter-room', function() {
		return RocketChat.TabBar.addButton(
			settings,
			RocketChat.callbacks.priority.MEDIUM,
			'enter-room-tabbar-example'
		);
	});
});

