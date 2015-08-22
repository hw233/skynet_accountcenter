local cjson = require "cjson"


local function sync(agent,query,header,body)
	local id = agent.id
	local gameflag = query.gameflag
	local srvname = query.srvname
	local acct = query.acct
	local roleid = tonumber(query.roleid)
	local syncdata = cjson.decode(body)
	syncdata.roleid = roleid
	local status = acctmgr.syncrole(acct,gameflag,srvname,syncdata)
	--pprintf("agent:%s,query:%s,header:%s,body:%s,status:%s",agent,query,header,body,status)
	return status
end

return sync
