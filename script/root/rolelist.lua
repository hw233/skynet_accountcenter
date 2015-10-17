local function rolelist(agent,query,header,body)
	local id = agent.id
	local acct = query.acct
	local gameflag = query.gameflag
	local srvname = query.srvname
	local acctobj = acctmgr.getacct(acct)
	if not acctobj then
		return STATUS_ACCT_NOEXIST
	end
	
	local status,rolelist = acctmgr.getrolelist(acct,gameflag,srvname)
	if status == STATUS_OK then
		return status,rolelist
	else
		return status
	end
end

return rolelist
