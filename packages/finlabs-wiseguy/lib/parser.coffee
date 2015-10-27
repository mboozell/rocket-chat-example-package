FinLabs.WiseGuy.parse =
  ticker: (alert) ->
    /^([\w-]+)/.exec(alert)[1]
  state: (alert) ->
    result = /BULLISH/.exec(alert)
    if result then 1 else -1
  exp_date: (alert) ->
    result = /(?:\:\s)(.*)(?:\s(?:\d|\.)+\s(?:CALLS|PUTS))/.exec(alert)[1]
    exp_date = new Date result
    today = new Date
    year = 1900 + today.getYear()
    exp_date.setFullYear year
    if today - exp_date > 100000
      exp_date.setFullYear year + 1
    exp_date
  tags: (alert) ->
    result = /(?:BET\s)((\S*\s)+)(?:\w+=)/.exec(alert)[1]
    result = result.split('/')
    _.map result, _.trim
  order: (alert) ->
    result = /([\d\.]+)(?:\s(?:CALLS|PUTS))/.exec(alert)[0]
    parseFloat result
  direction: (alert) ->
    result = /CALLS/.exec(alert)
    if result then 1 else -1
  price: (alert) ->
    result = /(?:\$)(\d*)(?:k)/.exec(alert)[1]
    parseInt(result)*1000
  weekly: (alert) ->
    result = /\(Wkly\)/.exec(alert)
    if result then true else false

FinLabs.WiseGuy.parseAll = (alert) ->
  result = {}
  for key, parser of FinLabs.WiseGuy.parse
    result[key] = parser alert
  result
