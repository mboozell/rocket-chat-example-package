Analytics = Npm.require 'analytics-node'
key = RocketChat.settings.get 'Segment_Key'

if key
  FinLabs.Analytics = new Analytics key

  FinLabs.Analytics.track = (->
    _track = FinLabs.Analytics.track
    (event, properties, context) ->
      _track
        userId: Meteor.userId()
        event: event
        properties: properties
        context: context
  )()

  FinLabs.Analytics.page = (->
    _page = FinLabs.Analytics.page
    (name, properties, category) ->
      _page
        userId: Meteor.userId()
        category: category
        name: name
        properties: properties
  )()

  FinLabs.Analytics.group = (->
    _group = FinLabs.Analytics.group
    (groupId, traits) ->
      _group
        userId: Meteor.userId()
        groupId: groupId
        traits: traits
  )()
