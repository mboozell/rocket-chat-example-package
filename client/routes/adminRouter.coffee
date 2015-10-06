tabReset = ->
	RocketChat.TabBar.reset()

FlowRouter.route '/admin/users',
	name: 'admin-users'
	triggersEnter: [tabReset]
	triggersExit: [tabReset]
	action: ->
		BlazeLayout.render 'main', {center: 'adminUsers'}


FlowRouter.route '/admin/rooms',
	name: 'admin-rooms'
	triggersEnter: [tabReset]
	triggersExit: [tabReset]
	action: ->
		BlazeLayout.render 'main', {center: 'adminRooms'}


FlowRouter.route '/admin/statistics',
	name: 'admin-statistics'
	triggersEnter: [tabReset]
	triggersExit: [tabReset]
	action: ->
		BlazeLayout.render 'main', {center: 'adminStatistics'}

FlowRouter.route '/admin/integrations',
	name: 'admin-integrations'
	triggersEnter: [tabReset]
	triggersExit: [tabReset]
	action: ->
		BlazeLayout.render 'main', {center: 'adminIntegrations'}


FlowRouter.route '/admin/:group?',
	name: 'admin'
	triggersEnter: [tabReset]
	triggersExit: [tabReset]
	action: ->
		BlazeLayout.render 'main', {center: 'admin'}
