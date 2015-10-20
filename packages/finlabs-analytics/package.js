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
		'rocketchat:lib@0.0.1'
	]);

	api.use([], 'server');
	api.use([], 'client');

	Npm.depends({
		'stripe': '4.0.0'
	});


	api.addFiles([], ['server', 'client']);

	api.addFiles([], 'server');

	api.addFiles([], 'client');

});

Package.onTest(function(api) {

});
