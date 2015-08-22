

local function createrole(agent,query,header,body)
	local id = agent.id	
	local acct = query.acct
	local gameflag = query.gameflag
	local srvname = query.srvname
	local roleid = tonumber(query.roleid)
	local name = query.name
	local roletype = query.roletype
	local status = acctmgr.addrole(acct,gameflag,srvname,{
		roleid = roleid,
		name = name,
		roletype = roletype,
	})
	return status
end

return createrole
