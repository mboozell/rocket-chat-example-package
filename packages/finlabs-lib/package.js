Package.describe({
	name: 'finlabs:lib',
	version: '0.0.1',
	summary: 'finlabs Utils',
	git: ''
});

Package.onUse(function(api) {
	api.versionsFrom('1.0');

	api.use([
		'coffeescript',
		'underscore'
	]);

	api.use([], 'server');
	api.use([], 'client');

	api.addFiles("lib/core.coffee");

	api.addFiles([], ['server', 'client']);

	api.addFiles([], 'server');

	api.addFiles([], 'client');

	api.export("FinLabs");
});

Package.onTest(function(api) {

});
