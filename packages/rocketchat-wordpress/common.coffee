config =
	serverURL: 'https://www.sanglucci.com/'
	identityPath: 'oauth/me'
	tokenPath: 'oauth/token'
	addAutopublishFields:
		forLoggedInUser: ['services.wordpress']
		forOtherUsers: ['services.wordpress.user_login']

WordPress = new CustomOAuth 'wordpress', config

if Meteor.isServer
	Meteor.startup ->
		RocketChat.models.Settings.find({ _id: 'Accounts_OAuth_Wordpress_url' }).observe
			added: (record) ->
				config.serverURL = RocketChat.settings.get 'Accounts_OAuth_Wordpress_url'
				WordPress.configure config
			changed: (record) ->
				config.serverURL = RocketChat.settings.get 'Accounts_OAuth_Wordpress_url'
				WordPress.configure config
else
	Meteor.startup ->
		Tracker.autorun ->
			if RocketChat.settings.get 'Accounts_OAuth_Wordpress_url'
				config.serverURL = RocketChat.settings.get 'Accounts_OAuth_Wordpress_url'
				WordPress.configure config
