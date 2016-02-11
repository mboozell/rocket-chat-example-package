FinLabs.payment.orders =

	handleNew: (order) ->
		unless order.status == 'paid'
			return

		unless FinLabs.models.Trial.findOneBySKU order.sku
			return

		if RocketChat.models.Users.findOneByEmailAddress order.email
			return FinLabs.payment.orders.refundOrder order
		return FinLabs.payment.orders.createInvite order

	refundOrder: (order) ->
		try
			FinLabs.payment.util.refundCharge order.charge
			FinLabs.payment.util.updateOrder order.orderId, status: 'canceled'

		FinLabs.lib.emailTemplate "refundEmail", order.email, {}, subject: "Your Order has been Refunded!"

	createInvite: (order) ->
		unless RocketChat.models.Invitations.findOneByEmail order.email
			invitation = RocketChat.models.Invitations.createOneWithEmail order.email, order: order._id
			invitation.url = "#{Meteor.absoluteUrl()}register?invite=#{encodeURIComponent(invitation.key)}"

			FinLabs.lib.emailInvite invitation


