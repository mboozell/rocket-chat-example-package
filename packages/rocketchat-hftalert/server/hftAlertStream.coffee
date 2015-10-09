RocketChat.hftAlert.stream = new Meteor.Stream 'hftAlert'
RocketChat.hftAlert.stream.permissions.write -> false
RocketChat.hftAlert.stream.permissions.read -> true
