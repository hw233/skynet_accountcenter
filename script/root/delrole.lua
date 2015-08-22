

local function delrole(agent,query,header,body)
	local id = agent.id
	local acct = query.acct
	local gameflag = query.gameflag
	local srvname = query.srvname
	local roleid = tonumber(query.roleid)
	return acctmgr.delrole(acct,gameflag,srvname,roleid)
end

return delrole
