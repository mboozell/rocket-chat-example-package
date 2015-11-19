FinLabs.payment.products = new class

	add: (name, roles, payments, options) ->
		FinLabs.models.Product.upsert name, roles, payments, options



