Package.describe({
	name: 'rocketchat:hftalert',
	version: '0.0.1',
	summary: 'HFT Alert Utilities',
	git: ''
});

Package.onUse(function(api) {
	api.versionsFrom('1.0');

	api.use([
		'coffeescript',
		'mongo',
		'jalik:ufs',
		'jalik:ufs-gridfs',
		'rocketchat:lib@0.0.1',
		'percolate:synced-cron'
	]);

	Npm.depends({
		'gridfs-stream': '1.1.1',
		'request': '2.64.0'
	})

	api.addFiles('hftalert.coffee', ['server', 'client']);
	api.addFiles('server/settings.coffee', ['server']);
	api.addFiles('server/getDelineatorImage.coffee', ['server']);
	api.addFiles('server/startup/imageCron.coffee', ['server']);
});

Package.onTest(function(api) {

});
