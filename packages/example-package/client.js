Template.examplePackageMain.helpers({
	buttonName: function() {
		return "Button";
	}
});

Template.examplePackageMain.events({
	'click #button': function(event, template) {
		Meteor.call('exampleMethod', data, function(error, response) {
			// do something with response
		});
	}
});

Template.examplePackageMain.onCreated(function () {
	var ready = new ReactiveVar(false);
	// load reactive vars in here
	//
	// reactive vars used in helper functions or Template.autorun
	// functions get automatically reloaded on reactive var changes
});

Template.examplePackageMain.onRendered(function() {
	// load external js in here probably
});
