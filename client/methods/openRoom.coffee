Meteor.methods
  openRoom: (rid) ->
    if not Meteor.userId()
      throw new Meteor.Error 'invalid-user', '[methods] openRoom -> Invalid user'

    ChatSubscription.update
      rid: rid
      'u._id': Meteor.userId()
    ,
      $set:
        open: true

    FinLabs.Analytics.track( 'Open Room', {
      roomId: rid
      username: Meteor.users.findOne(this.userId).username
      })
