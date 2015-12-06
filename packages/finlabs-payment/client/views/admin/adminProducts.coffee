Template.adminProducts.helpers

	isReady: ->
		return Template.instance().ready.get()
	products: ->
		return Template.instance().products()
	flexTemplate: ->
		return RocketChat.TabBar.getTemplate()
	flexData: ->
		return RocketChat.TabBar.getData()
	flexOpened: ->
		return 'opened' if RocketChat.TabBar.isFlexOpen()
	arrowPosition: ->
		return 'left' unless RocketChat.TabBar.isFlexOpen()

Template.adminProducts.onCreated ->
	instance = @
	@ready = new ReactiveVar false

	@autorun ->
		subscription = instance.subscribe 'products'
		instance.ready.set subscription.ready()

	@autorun ->
		if Session.get 'adminSelectedProduct'
			product = FinLabs.models.Product.findOne(Session.get 'adminSelectedProduct')
			if product
				instance.subscribe 'productChannels', product._id
				RocketChat.TabBar.setData product
				RocketChat.TabBar.addButton({ id: 'product-info', i18nTitle: t('Product_Info'), icon: 'icon-user', template: 'adminProductInfo', order: 1 })
				RocketChat.TabBar.addButton({ id: 'product-channels', i18nTitle: t('Product_Channels'), icon: 'icon-user', template: 'adminProductChannels', order: 2 })
				RocketChat.TabBar.addButton({ id: 'product-users', i18nTitle: t('Product_Users'), icon: 'icon-user', template: 'adminProductUsers', order: 2 })
				return
		RocketChat.TabBar.reset()

	@products = ->
		FinLabs.models.Product.find()

Template.adminProducts.onRendered ->
	Tracker.afterFlush ->
		SideNav.setFlex "adminFlex"
		SideNav.openFlex()

Template.adminProducts.events
	'click .submit .button': (e, instance) ->
		form = $('input[name="product_name"]')
		name = form.val()
		Meteor.call 'createProduct', name, (error, result) ->
			if result
				form.val('')
			if error
				toastr.error error.reason

	'click .flex-tab .more': ->
		if RocketChat.TabBar.isFlexOpen()
			RocketChat.TabBar.closeFlex()
		else
			RocketChat.TabBar.openFlex()

	'click .product-info': (e) ->
		e.preventDefault()
		productId = $(e.currentTarget).data('productid')
		Session.set 'adminSelectedProduct', productId
		RocketChat.TabBar.setTemplate 'adminProductInfo'
		RocketChat.TabBar.openFlex()

	'click .info-tabs a': (e) ->
		e.preventDefault()
		$('.info-tabs a').removeClass 'active'
		$(e.currentTarget).addClass 'active'

		$('.user-info-content').hide()
		$($(e.currentTarget).attr('href')).show()
