window.analytics = window.analytics or []

# A list of the methods in window.analytics.js to stub.
FinLabs.Analytics.methods = [
  'trackSubmit'
  'trackClick'
  'trackLink'
  'trackForm'
  'pageview'
  'identify'
  'reset'
  'group'
  'track'
  'ready'
  'alias'
  'page'
  'once'
  'off'
  'on'
]

# Define a factory to create stubs. These are placeholders
# for methods in window.analytics.js so that you never have to wait
# for it to load to actually record data. The `method` is
# stored as the first argument so we can replay the data.
FinLabs.Analytics.factory = (method) ->
  return ->
    args = Array.prototype.slice.call(arguments)
    args.unshift(method)
    window.analytics.push(args)
    return window.analytics

# For each of our methods generate a queueing stub.
for method in FinLabs.Analytics.methods
  FinLabs.Analytics[method] = FinLabs.Analytics.factory(method)

# Define a method to load window.analytics.js from our CDN
# and that will be sure to only ever load it once.
FinLabs.Analytics.load = (key) ->
  # Create an async script element based on your key.
  script = document.createElement 'script'
  script.type = 'text/javascript'
  script.onload = -> FinLabs.Analytics = window.analytics
  script.async = true
  script.src = "https://cdn.segment.com/analytics.js/v1/#{key}/analytics.min.js"

  # Insert our script next to the first script element.
  scripts = document.getElementsByTagName 'script'
  scripts[0].parentNode.insertBefore script, scripts[0]

FinLabs.Analytics.identifyMeteorUser = ->
  user = Meteor.user()
  if user
    FinLabs.Analytics.identify user._id,
      name: user.name
      email: user.emails[0].address
      roles: user.roles.__global_roles__
      username: user.username

# Add a version to keep track of what's in the wild.
window.analytics.SNIPPET_VERSION = '3.1.0'

Meteor.startup ->
  # Load window.analytics.js with your key which will automatically
  # load the tools you've enabled for your account. Boosh!
  key = RocketChat.settings.get 'Segment_Key'

  if key
    FinLabs.Analytics.load key


    FlowRouter.triggers.enter [
      (route) ->
        FinLabs.Analytics.page route.route.name,
          path: route.path
          url: window.location.origin + route.path
    ]

    RocketChat.callbacks.add 'enter-room', FinLabs.Analytics.identifyMeteorUser
    , RocketChat.callbacks.priority.MEDIUM, 'enter-room-identify-analytics'

