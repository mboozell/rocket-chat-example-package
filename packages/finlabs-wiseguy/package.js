Package.describe({
	name: 'finlabs:wiseguy',
	version: '0.0.1',
	summary: 'Module for pushing wiseguy alerts to a sidebar',
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

	api.use([
		"nimble:restivus"
	], 'server');

	api.use([], 'client');

	api.addFiles([
		"lib/core.coffee",
		"lib/parser.coffee"
	], ['server', 'client']);

	api.addFiles([
		"server/restapi/v1/alerts.coffee",
		"server/saveAlert.coffee"
	], 'server');

	api.addFiles([
	], 'client');

});

Package.onTest(function(api) {

});
