FinLabs.WiseGuy.parse =
	ticker: (alert) ->
		/^([\w-]+)/.exec(alert)[1]
	state: (alert) ->
		result = /BULLISH/.exec(alert)
		if result then 1 else -1
	exp_date: (alert) ->
		result = /(?:\:\s)(.*)(?:\s(?:\d|\.)+\s(?:CALLS|PUTS))/.exec(alert)[1]
		weekly = result.split(" ").length > 1
		exp_date = new Date result
		# set year
		today = new Date
		year = today.getFullYear()
		unless weekly
			year = parseInt("20" + result.substr(3,2))
		exp_date.setFullYear year
		if weekly and today > exp_date
			exp_date.setFullYear year + 1
		# set day to 3rd Friday
		unless weekly
			third_fri = new Date exp_date
			third_fri.setDate 1
			while third_fri.getDay() isnt 5
				third_fri.setDate third_fri.getDate() + 1
			exp_date.setDate third_fri.getDate() + 14
		exp_date
	tags: (alert) ->
		result = /(?:BET\s)((\S*\s)+)(?:\w+=)/.exec(alert)[1]
		result = result.split('/')
		_.map result, _.trim
	order: (alert) ->
		result = /([\d\.]+)(?:\s(?:CALLS|PUTS))/.exec(alert)[0]
		parseFloat result
	direction: (alert) ->
		result = /CALLS/.exec(alert)
		if result then 1 else -1
	price: (alert) ->
		result = /\$(\d|\.)+(k|m)/.exec(alert)[0]
		num = parseFloat(result.substring(1, result.length - 1))
		scale = switch result[result.length - 1]
			when "k" then 1e3
			when "m" then 1e6
			else 1
		num * scale
	weekly: (alert) ->
		result = /\(Wkly\)/.exec(alert)
		if result then true else false
	ref_price: (alert) ->
		result = /(?:[A-Z]{1,4}=)((\d|\.)+)/.exec(alert)[1]
		parseFloat result

FinLabs.WiseGuy.parseAll = (alert) ->
	result = {}
	for key, parser of FinLabs.WiseGuy.parse
		try
			result[key] = parser alert
	result
