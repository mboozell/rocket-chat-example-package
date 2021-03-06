Template.wiseGuyAlerts.helpers

	alerts: ->
		return Template.instance().alerts()

	hasAlerts: ->
		return WiseGuyAlerts.find({}, { sort: { ts: -1 } }).count() > 0

	groupDate: ->
		return moment(@ts).format('LL')

	isEqual: ->
		previousDate = WiseGuyAlerts.find({ts: {$gt: @ts}}, {sort: {ts: 1}, limit:1}).fetch()
		if previousDate.length is 0
			return true
		unless previousDate[0].ts.getDay() is @ts.getDay()
			return true

	isLast: ->
		nextDate = WiseGuyAlerts.find({ts: {$lt: @ts}}, {sort: {ts: -1}, limit:1}).fetch()
		if nextDate.length is 0
			return false
		unless nextDate[0].ts.getDay() is @ts.getDay()
			return false
		return true

	tags: ->
		@tags.join(' / ')

	timestamp: ->
		return moment(@ts).format('HH:mm:ss')

	getState: ->
		if @state is 1 then 'bullish' else 'bearish'

	formatDate: ->
		if @weekly
			return "Fri #{@exp_date.getMonth() + 1}/#{@exp_date.getUTCDate()}"
		"#{@exp_date.toDateString().substr(4,3)}#{@exp_date.toDateString().substr(13,2)}"

	getStrike: ->
		@order.toFixed 1

	getDirection: ->
		if @direction is 1 then 'CALLS' else 'PUTS'

	formatPrice: ->
		formattedPrice = @price
		if @price >= 1e6
			formattedPrice = (@price/1e6).toFixed(2) + 'M'
		else if @price >= 1e3
			formattedPrice = (@price/1e3).toFixed() + 'K'
		return formattedPrice

	refPrice: ->
		return @ref_price

	moreResults: ->
		return Template.instance().hasMore.get()

Template.wiseGuyAlerts.onCreated ->
	@hasMore = new ReactiveVar true
	@limit = new ReactiveVar 20
	@autorun =>
		sub = @subscribe 'wiseGuyAlerts', @limit.get()
		if sub.ready()
			if WiseGuyAlerts.find().count() < @limit.get()
				@hasMore.set false

	@alerts = ->
		return WiseGuyAlerts.find({}, {sort: ts: -1}).fetch()

Template.wiseGuyAlerts.events
	'click .alert-wrap': (e) ->
		e.preventDefault()
		ct = $(e.currentTarget)
		ct.children('.more-info').slideToggle('fast')
		ct.children('.wiseguy-alert').toggleClass('wiseguy-plus')

	'click .load-alerts': (e, template) ->
		e.preventDefault()
		template.limit.set(template.limit.get() + 10)

Template.wiseGuyAlerts.onRendered ->
	Meteor.defer ->
		if Meteor.user()?.settings?.preferences?.enableNewWiseguyAlertNotification
			$('#wiseguyNotification')[0].play()

		if !(RocketChat.TabBar.isFlexOpen('wiseGuyAlerts'))
			element = $('.tab-button[data-template="wiseGuyAlerts"]')
			element.addClass('blink').delay(2000).queue (next) ->
				$(this).removeClass('blink')
				next()
