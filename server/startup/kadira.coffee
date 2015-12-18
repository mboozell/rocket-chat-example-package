# updateKadira = ->
kadira_id = RocketChat.settings.get 'Kadira_App_Id'
kadira_secret = RocketChat.settings.get 'Kadira_App_Secret'

if kadira_id and kadira_secret
	Kadira.connect kadira_id, kadira_secret

# RocketChat.models.Settings.find({ '_id': /Kadira.*/ }).observe
# 	added: updateKadira
# 	changed: updateKadira
# 	removed: updateKadira
