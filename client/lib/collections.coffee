@ChatMessage = new Meteor.Collection null
@ChatRoom = new Meteor.Collection 'rocketchat_room'
@ChatSubscription = new Meteor.Collection 'rocketchat_subscription'
@Integrations = new Meteor.Collection 'rocketchat_integrations'
@UserAndRoom = new Meteor.Collection null
@CachedChannelList = new Meteor.Collection null
