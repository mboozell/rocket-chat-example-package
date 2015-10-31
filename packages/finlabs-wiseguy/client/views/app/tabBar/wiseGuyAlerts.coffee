Template.wiseGuyAlerts.helpers
	alerts: ->
		return Template.instance().alerts()

	groupDate: ->
		return moment(this.ts).format('LL')

	timestamp: ->
		return this.ts.toTimeString().substr(0,8)

	getState: ->
		if this.state is 1 then 'bullish' else 'bearish'

	formatDate: ->
		return this.exp_date.toDateString().substr(4,3) + this.exp_date.toDateString().substr(13,2)

	getDirection: ->
		if this.direction is 1 then 'CALLS' else 'PUTS'

	isWeekly: ->
		if this.weekly is true then '(Weekly)' else ''

	formatPrice: ->
		if this.price > 999 then (this.price/1000).toFixed() + 'K' else this.price

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
