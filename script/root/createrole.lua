
local function createrole(agent,query,header,body)
	local id = agent.id	
	local acct = query.acct
	local gameflag = query.gameflag
	local srvname = query.srvname
	if query.genroleid then
		roleid = acctmgr.genroleid()
	else
		roleid = tonumber(query.roleid)
	end
	assert(roleid,"no roleid")
	local role = cjson.decode(body)
	role.roleid = roleid
	local status = acctmgr.addrole(acct,gameflag,srvname,role)
	return status
end

return createrole
