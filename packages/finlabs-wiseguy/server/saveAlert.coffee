FinLabs.WiseGuy.saveAlert = (alert, key) ->

  unless alert
    throw new Meteor.Error 500, 'Invalid WiseGuy Alert'

  integration = RocketChat.models.Integrations.findOneByKey(key)

  if not integration
    throw new Meteor.Error 401, 'Bad API Key -> Not Authorized'

  ticker = FinLabs.WiseGuy.parse.ticker alert
  state = FinLabs.WiseGuy.parse.state alert
  date = FinLabs.WiseGuy.parse.date alert
  weekly = FinLabs.WiseGuy.parse.weekly alert
  order = FinLabs.WiseGuy.parse.order alert
  price = FinLabs.WiseGuy.parse.price alert

  console.log ticker
  console.log state
  console.log date
  console.log weekly
  console.log order
  console.log price
