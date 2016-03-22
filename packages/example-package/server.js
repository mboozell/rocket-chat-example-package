var OpenTok = Npm.require('opentok'),
	apiKey = "key",
	apiSecret = "secret",
	openTok = new OpenTok(apiKey, apiSecret);

Meteor.methods({
	exampleMethod: function(data) {
		syncMethod = Meteor.wrapAsync(openTok.method);
		response = syncMethod(method);
		return response;
	}
});
