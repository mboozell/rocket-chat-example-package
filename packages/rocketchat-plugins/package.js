Package.describe({
	name: 'rocketchat:hftalert',
	version: '0.0.1',
	summary: 'HFT Alert Utilities',
	git: ''
});

Package.onUse(function(api) {
	api.versionsFrom('1.0');

	api.use([
		'coffeescript'
	]);

});

Package.onTest(function(api) {

});
