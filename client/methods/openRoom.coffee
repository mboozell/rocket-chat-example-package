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

    FinLabs?.Analytics?.track( 'Open Room', {
      room: ChatRoom.findOne(rid).name
      username: Meteor.user().name
      roomType: ChatRoom.findOne(rid).t
      users: ChatRoom.findOne(rid).usernames
      })
