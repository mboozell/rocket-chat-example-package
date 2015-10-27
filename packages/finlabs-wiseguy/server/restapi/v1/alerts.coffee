Api = new Restivus
  version: 'v1'
  useDefaultAuth: true
  prettyJson: true

# curl -d "data=AKAM BEARISH WISEGUY ACTION: Feb16 67.5 PUTS $120k BET OPENING Pre-Earnings ARCA SPLIT AKAM=75.53 Ref 4.6x Usual Vol&apiKey=ToHmoq78KSoeBCpseoWfgE7tbv-QpnYBwB15ayNA0r3" http://localhost:3000/api/v1/plugins/wiseguy/alert

Api.addRoute 'plugins/wiseguy/alert', authRequired: false,
  post: ->
    try
      FinLabs.WiseGuy.saveAlert @bodyParams.data, @bodyParams.apiKey
      status: 'success'
    catch e
      console.log e
      statusCode: e.error
      body: satus: 'fail', reason: e.reason
