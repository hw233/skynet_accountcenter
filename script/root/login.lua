
local function login(agent,query,header,body)
	local id = agent.id
	local acct = query.acct
	local passwd = query.passwd
	local ip = query.ip
	if banlogin.isbanacct(acct) then
		return STATUS_BANACCT
	elseif banlogin.isbanip(ip) then
		return STATUS_BANIP
	end
	local acctobj = acctmgr.getacct(acct)
	pprintf("%s",acctobj)
	if not acctobj then
		return STATUS_ACCT_NOEXIST
	end
	if passwd ~= acctobj.passwd then
		return STATUS_PASSWD_NOMATCH
	end
	return STATUS_OK
end

return login
