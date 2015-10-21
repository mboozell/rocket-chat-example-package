Package.describe({
	name: 'finlabs:analytics',
	version: '0.0.1',
	summary: 'finlabs Analytical Utils',
	git: ''
});

Package.onUse(function(api) {
	api.versionsFrom('1.0');

	api.use([
		'coffeescript',
		'underscore',
		'rocketchat:lib@0.0.1',
		'finlabs:lib@0.0.1'
	]);

	api.use([], 'server');
	api.use([], 'client');

	Npm.depends({
		'analytics-node': '2.0.0'
	});


	api.addFiles([
		"lib/core.coffee"
	], ['server', 'client']);

	api.addFiles([
		"server/analytics.coffee",
		"server/settings.coffee"
	], 'server');

	api.addFiles([
		"client/analytics.coffee"
	], 'client');

});

Package.onTest(function(api) {

});
