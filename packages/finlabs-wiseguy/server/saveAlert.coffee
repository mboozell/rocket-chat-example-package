FinLabs.WiseGuy.saveAlert = (alert, key) ->

  unless alert
    throw new Meteor.Error 500, 'Invalid WiseGuy Alert'

  product = FinLabs.models.Product.findOneByKey(key)

  if not product
    throw new Meteor.Error 401, 'Bad API Key -> Not Authorized'

  data = FinLabs.WiseGuy.parseAll alert

  FinLabs.models.WiseGuyAlerts.createOneWithApiKey data, key

