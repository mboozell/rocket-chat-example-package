FinLabs.payment.tools =

	add: (name, roles) ->
		FinLabs.models.Tool.upsertOneWithRoles name, roles

	getRoles: (name) ->
		tool = FinLabs.models.Tool.findOneByName name
		return if tool then tool.roles else []
