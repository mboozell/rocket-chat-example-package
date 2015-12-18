Api = new Restivus
	version: 'v1'
	useDefaultAuth: true
	prettyJson: true

Api.addRoute 'payment/invitation', authRequired: false,
	post: ->
		try
			{api_key, email, stripe_customer_id, stripe_subscription_id} = @bodyParams
			stripe =
				customer: stripe_customer_id,
				subscription: stripe_subscription_id
			FinLabs.payment.addAndSendInvitation email, stripe, api_key
			status: 'success'
		catch e
			console.log e
			statusCode: e.error
			body:
				status: 'fail',
				reason: e.reason
				stack: e.stack

