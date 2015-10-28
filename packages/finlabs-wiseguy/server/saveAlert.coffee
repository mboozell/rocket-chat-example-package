FinLabs.WiseGuy.saveAlert = (alert, key) ->

  unless alert
    throw new Meteor.Error 500, 'Invalid WiseGuy Alert'

  integration = RocketChat.models.Integrations.findOneByKey(key)

  if not integration
    throw new Meteor.Error 401, 'Bad API Key -> Not Authorized'

  data = FinLabs.WiseGuy.parseAll alert

  FinLabs.models.WiseGuyAlerts.createOneWithApiKey data, key

