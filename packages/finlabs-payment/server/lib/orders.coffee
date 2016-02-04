FinLabs.payment.orders =

	handleNew: (order) ->
		unless order.status == 'paid'
			return

		order = FinLabs.models.Order.findOneByOrderId order.id
		unless FinLabs.models.Trial.findeOneBySKU order.sku
			return

		if FinLabs.models.Users.findOneByEmailAddress order.email
			return FinLabs.payment.orders.refundOrder order
		return FinLabs.payment.orders.createInvite order

	refundOrder: (order) ->
		try
			FinLabs.payment.util.refundCharge order.charge

		FinLabs.lib.emailTemplate "refundEmail", order.email, {}, subject: "Your Order has been Refunded!"

	createInvite: (order) ->
		invitation = RocketChat.models.Invitations.createOneWithEmail order.email, order: order._id
		invitation.url = "#{Meteor.absoluteUrl()}register?invite=#{encodeURIComponent(invitation.key)}"

		FinLabs.lib.emailInvite invitation


