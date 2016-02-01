Meteor.methods
	isProduction: () ->
		process.env.ENVIRONMENT is 'Web.Production'
