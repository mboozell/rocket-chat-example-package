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
		'underscore',
		'rocketchat:lib@0.0.1',
		'reactive-var'
	]);

	api.use([
		'mongo',
		'webapp'
	], 'server')

	Npm.depends({
		'gridfs-stream': '1.1.1',
		'request': '2.64.0'
	})

	// TAPi18n
	api.use('templating', 'client');
	var _ = Npm.require('underscore');
	var fs = Npm.require('fs');
	tapi18nFiles = _.compact(_.map(fs.readdirSync('packages/rocketchat-hftalert/i18n'), function(filename) {
		if (fs.statSync('packages/rocketchat-hftalert/i18n/' + filename).size > 16) {
			return 'i18n/' + filename;
		}
	}));
	api.use(["tap:i18n@1.5.1"], ["client", "server"]);
	api.imply('tap:i18n');
	api.addFiles("package-tap.i18n", ["client", "server"]);
	api.addFiles(tapi18nFiles, ["client", "server"]);

	api.addFiles('hftalert.coffee', ['server', 'client']);

	api.addFiles([
		'server/hftAlertSettings.coffee',
		'server/hftAlertStream.coffee',
		'server/getDelineatorImage.coffee',
		'server/hftAlertStore.coffee',
		'server/downloadDelineatorImage.coffee',
		'server/startup/imageCron.coffee'
	], 'server');

	api.addFiles([
		'client/views/app/tabBar/hftAlerts.html',
		'client/views/app/tabBar/hftAlerts.coffee',
		'client/hftAlertTabBar.coffee'
	], 'client');

});

Package.onTest(function(api) {

});
