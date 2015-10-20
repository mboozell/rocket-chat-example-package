FinLabs.hftAlert.settings =
	downloadRoute: /^\/plugins\/hftalert\/image\/(.*)$/
	referer: "http://www.sghammer.com/users/journal/index.html"
	images:
		'5min':
			url: "http://www.hcmi.com/users/subscribers/Advanced/5min/Delin_ny.jpg"
			name: "5min.jpg"
			type: "image/jpg"
			frequency: "every 1 min"
		'30min':
			url: "http://www.hcmi.com/users/subscribers/Advanced/30min/Delin_ny.jpg"
			name: "30min.jpg"
			type: "image/jpg"
			frequency: "every 5 min"
		'daily':
			url: "http://www.hcmi.com/users/subscribers/Advanced/30min/daily.jpg"
			name: "daily.jpg"
			type: "image/jpg"
			frequency: "every 1 hour"

FinLabs.hftAlert.stream.permissions.write -> false
FinLabs.hftAlert.stream.permissions.read -> true
