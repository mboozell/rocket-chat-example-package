Package.describe({
	name: 'finlabs:lib',
	version: '0.0.1',
	summary: 'finlabs Analytical Utils',
	git: ''
});

Package.onUse(function(api) {
	api.versionsFrom('1.0');

	api.use([
		'coffeescript',
		'underscore',
		'rocketchat:lib@0.0.1'
	]);

	api.use([], 'server');
	api.use([], 'client');

	api.addFiles([
		"finlabs.coffee"
	], ['server', 'client']);

	api.addFiles([], 'server');

	api.addFiles([], 'client');

});

Package.onTest(function(api) {

});
