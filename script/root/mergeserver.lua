

local function mergeserver(agent,query,header,body)
	local acct = query.acct
	local gameflag = query.gameflag
	local src_srvname = query.src_srvname
	local dst_srvname = query.dst_srvname
	local oldroleid = tonumber(query.oldroleid)
	local newroleid = tonumber(query.newroleid)
	return acctmgr.mergeserver(acct,gameflag,src_srvname,dst_srvname,oldroleid,newroleid)
end

return mergeserver
