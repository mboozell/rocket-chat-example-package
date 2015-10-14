RocketChat.settings.addGroup 'Payment'
RocketChat.settings.add 'Require_Payment', false, { type: 'boolean', group: 'Payment', public: true }
RocketChat.settings.add 'Price', 0, { type: 'float', group: 'Payment', public: true }
RocketChat.settings.add 'Stripe_Key', '', { type: 'string', group: 'Payment' }
