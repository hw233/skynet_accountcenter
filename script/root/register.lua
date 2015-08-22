
require "script.acctmgr"

local function register(agent,query,header,body)
	local id = agent.id
	local acct = query.acct
	local passwd = query.passwd
	local checkpasswd = query.checkpasswd
	local result = 0
	local extra = {}
	if checkpasswd ~= passwd then
		return STATUS_PASSWD_NOMATCH
	end
	if not string.match(acct,"%w+@%w+%.%w+") then
		return STATUS_ACCT_FMT_ERR
	end
	local account = acctmgr.getacct(acct)
	if account then
		return STATUS_ACCT_AREADY_EXIST
	end
	return acctmgr.addacct(acct,passwd)
end

return register
