Package.describe({
	name: 'mboozell:example-package',
	version: '0.0.1',
	summary: 'example',
	git: ''
});

Package.onUse(function(api) {
	api.versionsFrom('1.0');

	api.use([
		'rocketchat:lib@0.0.1',
	]);

	api.use([
		'templating'
	], 'client');

	Npm.depends({
		'opentok': '2.3.0'
	});

	api.addFiles([
		'server.js'
	], 'server');

	api.addFiles([
		'client.html',
		'client.js',
		'tabBar.js'
	], 'client');

});

