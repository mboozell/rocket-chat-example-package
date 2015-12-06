RocketChat.settings.addGroup 'Payment'
RocketChat.settings.add 'Require_Payment', false, { type: 'boolean', group: 'Payment', public: true }
RocketChat.settings.add 'Stripe_Public_Key', '', { type: 'string', group: 'Payment', public: true}
RocketChat.settings.add 'Stripe_Secret_Key', '', { type: 'string', group: 'Payment' }

FinLabs.payment = {}

Meteor.startup ->

	FinLabs.payment.products.add 'wsj-chat',
		['wiseguy-alerts'],
		['steam-room'],
		[
			{
				type: 'wordpress'
			}
		],
		baseProduct: true
		apiKey: "moUObG8aQLN24KWyxpv0VN3dGvP9G0tyt81_39l9ehX"

Meteor.startup ->

	permissions = [

		{ _id: 'view-product-administration',
		roles : ['admin']}

		{ _id: 'create-product',
		roles : ['admin']}

		{ _id: 'view-products',
		roles : ['admin']}

		{ _id: 'view-purchases',
		roles : ['admin']}

		{ _id: 'can-update-product',
		roles : ['admin']}

	]

	roles = _.pluck(Roles.getAllRoles().fetch(), 'name')

	for permission in permissions
		RocketChat.models.Permissions.upsert( permission._id, {$setOnInsert : permission })
		for role in permission.roles
			unless role in roles
				Roles.createRole role
				roles.push(role)
