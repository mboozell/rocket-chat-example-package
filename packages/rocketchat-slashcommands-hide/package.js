Package.describe({
	name: 'rocketchat:slashcommands-hide',
	version: '0.0.1',
	summary: 'Message pre-processor that will translate /hide commands',
	git: ''
});

Package.onUse(function(api) {
	api.versionsFrom('1.0');

	api.use([
		'coffeescript',
		'rocketchat:lib@0.0.1'
	]);
	api.addFiles('hide.coffee');
});

Package.onTest(function(api) {

});
