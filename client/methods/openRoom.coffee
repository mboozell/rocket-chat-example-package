Meteor.methods
  openRoom: (rid) ->
    FinLabs.Analytics.track 'Open Room'
    if not Meteor.userId()
      throw new Meteor.Error 'invalid-user', '[methods] openRoom -> Invalid user'

    ChatSubscription.update
      rid: rid
      'u._id': Meteor.userId()
    ,
      $set:
        open: true
