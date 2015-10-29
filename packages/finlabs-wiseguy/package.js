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
		'finlabs:lib@0.0.1',
		'rocketchat:authorization@0.0.1'
	]);

	api.use([
		"nimble:restivus",
		"alanning:roles"
	], 'server');

	api.use([
		"templating"
	], 'client');

	var _ = Npm.require('underscore');
	var fs = Npm.require('fs');
	tapi18nFiles = _.compact(_.map(fs.readdirSync('packages/finlabs-wiseguy/i18n'), function(filename) {
		if (fs.statSync('packages/finlabs-wiseguy/i18n/' + filename).size > 16) {
			return 'i18n/' + filename;
		}
	}));
	api.use(["tap:i18n@1.5.1"], ["client", "server"]);
	api.imply('tap:i18n');
	api.addFiles("package-tap.i18n", ["client", "server"]);
	api.addFiles(tapi18nFiles, ["client", "server"]);

	api.addFiles([
		"lib/core.coffee",
		"lib/parser.coffee"
	], ['server', 'client']);

	api.addFiles([
		"server/models/WiseGuyAlerts.coffee",
		"server/restapi/v1/alerts.coffee",
		"server/saveAlert.coffee",
		"server/publications/wiseGuyAlerts.coffee",
		"server/settings.coffee"
	], 'server');

	api.addFiles([
		"client/tabBar.coffee",
		"client/views/app/tabBar/wiseGuyAlerts.html",
		"client/views/app/tabBar/wiseGuyAlerts.coffee",
		"client/stylesheets/wiseguy.css",
		"client/lib/collections.coffee"
	], 'client');

});

Package.onTest(function(api) {

});
