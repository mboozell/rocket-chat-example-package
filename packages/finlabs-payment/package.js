Package.describe({
	name: 'finlabs:payment',
	version: '0.0.1',
	summary: 'finlabs Payment Utils',
	git: ''
});

Package.onUse(function(api) {
	api.versionsFrom('1.0');

	api.use([
		'coffeescript',
		'alanning:roles',
		'underscore',
		'rocketchat:lib@0.0.1',
		'finlabs:lib@0.0.1'
	]);

	api.use([
		"nimble:restivus",
		"http",
	], 'server');

	api.use([
		'templating',
		'less@2.5.0'
	], 'client');

	Npm.depends({
		'stripe': '4.0.0'
	});

	// TAPi18n
	var _ = Npm.require('underscore');
	var fs = Npm.require('fs');
	tapi18nFiles = _.compact(_.map(fs.readdirSync('packages/finlabs-payment/i18n'), function(filename) {
		if (fs.statSync('packages/finlabs-payment/i18n/' + filename).size > 16) {
			return 'i18n/' + filename;
		}
	}));
	api.use(["tap:i18n@1.5.1"], ["client", "server"]);
	api.imply('tap:i18n');
	api.addFiles("package-tap.i18n", ["client", "server"]);
	api.addFiles(tapi18nFiles, ["client", "server"]);

	api.addFiles([], ['server', 'client']);

	api.addFiles([
		'server/settings.coffee',
		'server/lib/util.coffee',
		'server/lib/tools.coffee',
		'server/lib/accounts.coffee',
		'server/lib/stripeEvents.coffee',
		'server/lib/products.coffee',
		'server/lib/purchases.coffee',
		'server/lib/updateUserFromInvitation.coffee',
		'server/lib/addAndSendInvitation.coffee',
		'server/methods/chargeChatSubscription.coffee',
		'server/methods/updateProductBaseStatus.coffee',
		'server/methods/addProductChannel.coffee',
		'server/methods/removeProductChannel.coffee',
		'server/methods/addProductUser.coffee',
		'server/methods/removeProductUser.coffee',
		'server/models/Customer.coffee',
		'server/models/Transaction.coffee',
		'server/models/Subscription.coffee',
		'server/models/Product.coffee',
		'server/models/Tool.coffee',
		'server/models/Referral.coffee',
		'server/models/Purchase.coffee',
		'server/publications/products.coffee',
		'server/publications/productChannels.coffee',
		'server/publications/productPurchases.coffee',
		'server/restapi/v1/webhooks.coffee',
		'server/restapi/v1/invitations.coffee'
	], 'server');

	api.addFiles([
		'client/lib/collections.coffee',
		'client/views/admin/productTabs/adminProductInfo.html',
		'client/views/admin/productTabs/adminProductInfo.coffee',
		'client/views/admin/productTabs/adminProductUsers.html',
		'client/views/admin/productTabs/adminProductUsers.coffee',
		'client/views/admin/productTabs/adminProductChannels.html',
		'client/views/admin/productTabs/adminProductChannels.coffee',
		'client/views/admin/adminProducts.html',
		'client/views/admin/adminProducts.coffee',
		'client/views/admin/inviteSubscriptionProducts.html',
		'client/views/admin/inviteSubscriptionProducts.coffee',
		'client/views/login/payment.html',
		'client/views/login/payment.coffee',
		'client/views/payment/form.html',
		'client/views/payment/form.coffee',
		'client/stylesheets/tagList.less',
		'client/stylesheets/payment.less'
	], 'client');

});

Package.onTest(function(api) {

});
