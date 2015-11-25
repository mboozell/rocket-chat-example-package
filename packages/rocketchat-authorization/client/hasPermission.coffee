atLeastOne = (toFind, toSearch) ->
	console.log 'toFind: ', toFind if window.rocketDebug
	console.log 'toSearch: ', toSearch if window.rocketDebug
	return  not _.isEmpty(_.intersection(toFind, toSearch))

all = (toFind, toSearch) ->
	toFind = _.uniq(toFind)
	toSearch = _.uniq(toSearch)
	return _.isEmpty( _.difference( toFind, toSearch))

Template.registerHelper 'hasPermission', (permission, scope) ->
	unless _.isString( scope )
		scope = Roles.GLOBAL_GROUP
	return hasPermission( permission, scope, atLeastOne)

RocketChat.authz.hasAllPermission = (permissions, scope=Roles.GLOBAL_GROUP, user=Meteor.userId()) ->
	return hasPermission( permissions, scope, all, user)

RocketChat.authz.hasAtLeastOnePermission = (permissions, scope=Roles.GLOBAL_GROUP, user=Meteor.userId()) ->
	return hasPermission(permissions, scope, atLeastOne, user)

hasPermission = (permissions, scope=Roles.GLOBAL_GROUP, strategy, user=Meteor.userId()) ->

	unless user
		return false

	unless RocketChat.authz.subscription.ready()
		return false

	permissions = [].concat permissions

	roleNames = Roles.getRolesForUser(user, scope)

	userPermissions = []
	for roleName in roleNames
		userPermissions = userPermissions.concat(_.pluck(ChatPermissions.find({roles : roleName }).fetch(), '_id'))

	return strategy( permissions, userPermissions)
