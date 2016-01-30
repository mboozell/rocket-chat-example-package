Template.inviteSubscriptionProducts.helpers
	selectionId: ->
		Template.instance().data.id

	selected: ->
		Template.instance().selected.get()

	autocompleteSettings: ->
		return {
			limit: 10
			rules: [
				{
					collection: FinLabs.models.Product
					field: 'name'
					template: Template.roomSearch
					matchAll: true
				}
			]
		}

Template.inviteSubscriptionProducts.onCreated ->
	instance = @
	@ready = new ReactiveVar false
	@selected = new ReactiveVar []

	@autorun ->
		subscription = instance.subscribe 'products'
		instance.ready.set subscription.ready()

	@autorun ->
		selected = instance.selected.get()
		$('#' + instance.data.id).trigger('productListChange', data: selected)

Template.inviteSubscriptionProducts.events
	'autocompleteselect input': (e, t, selection) ->
		selected = t.selected.get()
		unless _.findWhere(selected, {_id: selection._id})
			selected.push(selection)
			t.selected.set(selected)
		$(e.target).val("")

	'click .tag-list-item-delete': (e, t) ->
		selectedId = $(e.target).data('item-id')
		selected = t.selected.get()
		selected = _.reject(selected, (item) -> item._id == selectedId)
		t.selected.set(selected)



