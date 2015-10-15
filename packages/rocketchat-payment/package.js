Package.describe({
	name: 'rocketchat:payment',
	version: '0.0.1',
	summary: 'Rocketchat Payment Utils',
	git: ''
});

Package.onUse(function(api) {
	api.versionsFrom('1.0');

	api.use([
		'coffeescript',
		'underscore',
		'rocketchat:lib@0.0.1'
	]);

	api.use([], 'server')

	Npm.depends({
		'stripe': '4.0.0'
	})

	// TAPi18n
	api.use('templating', 'client');
	var _ = Npm.require('underscore');
	var fs = Npm.require('fs');
	tapi18nFiles = _.compact(_.map(fs.readdirSync('packages/rocketchat-payment/i18n'), function(filename) {
		if (fs.statSync('packages/rocketchat-payment/i18n/' + filename).size > 16) {
			return 'i18n/' + filename;
		}
	}));
	api.use(["tap:i18n@1.5.1"], ["client", "server"]);
	api.imply('tap:i18n');
	api.addFiles("package-tap.i18n", ["client", "server"]);
	api.addFiles(tapi18nFiles, ["client", "server"]);

	api.addFiles([], ['server', 'client']);

	api.addFiles([
		'server/startup.coffee'
	], 'server');

	api.addFiles([
		'client/views/login/payment.html',
		'client/views/login/payment.coffee',
		'client/views/payment/form.html',
		'client/views/payment/form.coffee'
	], 'client');

});

Package.onTest(function(api) {

});
