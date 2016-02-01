Package.describe({
	name: 'finlabs:slashcommands-alert',
	version: '0.0.1',
	summary: 'Message pre-processor that will translate /alert commands',
	git: ''
});

Package.onUse(function(api) {

	api.versionsFrom('1.0');

	api.use([
		'coffeescript',
		'check',
		'rocketchat:lib@0.0.1',
		'finlabs:lib@0.0.1',
		'alanning:roles@1.2.12'
	]);

	api.addFiles('lib.coffee', ['client', 'server']);
	api.addFiles('client.coffee', 'client');
	api.addFiles('server.coffee', 'server');
	api.addFiles('startup.coffee', 'server');

	// TAPi18n
	api.use('templating', 'client');
	var _ = Npm.require('underscore');
	var fs = Npm.require('fs');
	tapi18nFiles = _.compact(_.map(fs.readdirSync('packages/finlabs-slashcommands-alert/i18n'), function(filename) {
		if (fs.statSync('packages/finlabs-slashcommands-alert/i18n/' + filename).size > 16) {
			return 'i18n/' + filename;
		}
	}));
	api.use('tap:i18n');
	api.addFiles(tapi18nFiles);
});

Package.onTest(function(api) {

});
