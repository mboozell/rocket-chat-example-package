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
		
		

	timestamp: ->
		return moment(@ts).format('HH:mm:ss')

	getState: ->
		if @state is 1 then 'bullish' else 'bearish'

	formatDate: ->
		return @exp_date.toDateString().substr(4,3) + @exp_date.toDateString().substr(13,2)

	getDirection: ->
		if @direction is 1 then 'CALLS' else 'PUTS'

	isWeekly: ->
		if @weekly is true then '(Weekly)' else ''

	formatPrice: ->
		if @price > 999 then (@price/1000).toFixed() + 'K' else @price

Template.wiseGuyAlerts.onCreated ->
	instance = @
	@ready = new ReactiveVar true

	@autorun ->
		subscription = instance.subscribe 'wiseGuyAlerts', 20
		instance.ready.set subscription.ready()

	@alerts = ->
		return WiseGuyAlerts.find({}).fetch()

Template.wiseGuyAlerts.onRendered ->

Template.wiseGuyAlerts.events
	'click .alert-wrap': (e) ->
		e.preventDefault()
		ct = $(e.currentTarget)
		ct.children('.more-info').slideToggle('fast')
		ct.children('.wiseguy-alert').toggleClass('wiseguy-plus')
