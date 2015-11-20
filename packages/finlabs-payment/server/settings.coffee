RocketChat.settings.addGroup 'Payment'
RocketChat.settings.add 'Require_Payment', false, { type: 'boolean', group: 'Payment', public: true }
RocketChat.settings.add 'Stripe_Public_Key', '', { type: 'string', group: 'Payment', public: true}
RocketChat.settings.add 'Stripe_Secret_Key', '', { type: 'string', group: 'Payment' }

FinLabs.payment = {}

Meteor.startup ->

	FinLabs.payment.products.add 'wsj-chat',
		['wsj-user'],
		['beta-testers'],
		[
			{
				type: 'wordpress'
			}
		],
		baseProduct: true
		apiKey: "moUObG8aQLN24KWyxpv0VN3dGvP9G0tyt81_39l9ehX"
