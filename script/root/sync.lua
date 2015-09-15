
local function sync(agent,query,header,body)
	local id = agent.id
	local gameflag = query.gameflag
	local srvname = query.srvname
	local acct = query.acct
	local roleid = tonumber(query.roleid)
	local role = cjson.decode(body)
	role.roleid = roleid
	local status = acctmgr.syncrole(acct,gameflag,srvname,role)
	--pprintf("agent:%s,query:%s,header:%s,body:%s,status:%s",agent,query,header,body,status)
	return status
end

return sync
