RocketChat.settings.addGroup 'Payment', ->
	@add 'Require_Payment', false, { type: 'boolean',  public: true }
	@add 'Stripe_Public_Key', '', { type: 'string',  public: true}
	@add 'Stripe_Secret_Key', '', { type: 'string' }

FinLabs.payment = {}

# Meteor.startup ->
#
# 	FinLabs.payment.products.add 'wsj-chat',
# 		['wiseguy-alerts'],
# 		['steam-room'],
# 		[
# 			{
# 				type: 'wordpress'
# 			},
# 			{
# 				type: 'subscription'
# 				plan:
# 					id: 'wsj-chat'
# 			}
# 		],
# 		baseProduct: true
# 		apiKey: "moUObG8aQLN24KWyxpv0VN3dGvP9G0tyt81_39l9ehX"
# 		default: true

Meteor.startup ->

	permissions = [

		{ _id: 'view-product-administration',
		roles : ['admin']}

		{ _id: 'create-product',
		roles : ['admin']}

		{ _id: 'view-products',
		roles : ['admin', 'user', 'unpaid-user']}

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
