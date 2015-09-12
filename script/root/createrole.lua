
local function createrole(agent,query,header,body)
	local id = agent.id	
	local acct = query.acct
	local gameflag = query.gameflag
	local srvname = query.srvname
	local roleid = tonumber(query.roleid)
	local role = cjson.decode(body)
	role.roleid = roleid
	local status = acctmgr.addrole(acct,gameflag,srvname,role)
	return status
end

return createrole
