Template.flexTabBar.helpers
	active: ->
		return 'active' if @template is RocketChat.TabBar.getTemplate() and RocketChat.TabBar.isFlexOpen()
	buttons: ->
		return RocketChat.TabBar.getButtons()
	title: ->
		return t(@i18nTitle) or @title

Template.flexTabBar.events
	'click .tab-button': (e, t) ->
		e.preventDefault()
		template = $(e.currentTarget).data('template')
		if RocketChat.TabBar.isFlexOpen() and RocketChat.TabBar.getTemplate() is template
			RocketChat.TabBar.closeFlex()
		else
			RocketChat.TabBar.setTemplate template, ->
				$('.flex-tab')?.find("input[type='text']:first")?.focus()
				$('.flex-tab .content')?.scrollTop(0)

		t.currentTemplate.set(template)

Template.flexTabBar.onCreated ->
	instance = @
	@currentTemplate = new ReactiveVar RocketChat.TabBar.getTemplate()

	@resize = (width) ->
		if width?
			$('.flex-tab').css('max-width', "#{width}px")
			if window.matchMedia and window.matchMedia("(min-width: 780px)").matches
				$('#rocket-chat .main-content').css('right', "#{width}px")
			else
				$('#rocket-chat .main-content').css('right', "")
		else
			$('.flex-tab').css('max-width', '')
			$('#rocket-chat .main-content').css('right', "")

	@toggleResizer = (resizeable, onResize) ->
		if resizeable
			$('.flex-tab').prepend("<div class='tab-resizer'/>")
			dragging = null
			initialParams = {}
			$(document.body).on "mousemove", (e) ->
				if dragging
					deltaX = initialParams.offset.left - e.pageX
					width = initialParams.width + deltaX
					instance.resize(width)
					onResize?(width)
			$('.flex-tab .tab-resizer').on "mousedown", (e) ->
				dragging = $(e.target)
				initialParams =
					width: $('.flex-tab').width()
					offset: dragging.offset()
			$(document.body).on "mouseup", (e) ->
				dragging = null
				initialParams = {}
		else
			$('.flex-tab .tab-resizer').remove()


Template.flexTabBar.onRendered ->
	instance = Template.instance()

	Tracker.autorun ->
		template = instance.currentTemplate.get()
		resize = instance.resize
		toggleResizer = instance.toggleResizer
		if RocketChat.TabBar.isFlexOpen()
			button = _.findWhere(RocketChat.TabBar.getButtons(), template: template)
			if button
				console.log button
				resize(button.width)
				toggleResizer(button.resizeable, (newWidth) ->
					RocketChat.TabBar.updateButton button.id, width: newWidth
				)
		else
			resize()
			toggleResizer()
