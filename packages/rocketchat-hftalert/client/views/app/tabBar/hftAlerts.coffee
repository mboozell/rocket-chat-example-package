Template.hftAlerts.helpers
	tSearchMessages: ->
		return t('Search_Messages')

	searchResult: ->
		return Template.instance().searchResult.get()

Template.hftAlerts.events
	"keydown #message-search": (e) ->
		if e.keyCode is 13
			e.preventDefault()

	"keyup #message-search": _.debounce (e, t) ->
		t.searchResult.set undefined
		value = e.target.value.trim()
		if value is ''
			return


Template.hftAlerts.onCreated ->
	instance = @
	@imageNum = new ReactiveVar 0
	@stream = new Meteor.Stream 'hftAlert'


	console.log('happens')
	console.log(@stream)
	@stream.on 'new image', (data) -> console.log data
