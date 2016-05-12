banlogin = banlogin or {}

function banlogin.banip(ip,exceedtime,reason)
	exceedtime = exceedtime or 2 * 365 * 24 * 3600
	exceedtime = os.time() + exceedtime
	logger.log("info","banlogin",string.format("[banip] ip=%s exceedtime=%s reason=%s",ip,exceedtime,reason))
	local val = {
		exceedtime = exceedtime,
		reason = reason,
	}
	local db = dbmgr.getdb()
	local key = db:key("banlogin:ip",ip)
	db:set(key,val)
	db:expireat(key,exceedtime)
end

function banlogin.unbanip(ip,reason)
	local db = dbmgr.getdb()
	local key = db:key("banlogin:ip",ip)
	local isban,val = banlogin.isbanip(ip)
	if isban then
		logger.log("info","banlogin",string.format("[unbanip] ip=%s reason=%s",ip,reason))
		db:del(key)
		return val
	end
end

function banlogin.isbanip(ip)
	local db = dbmgr.getdb()
	local key = db:key("banlogin:ip",ip)
	local val = db:get(key)
	if val then
		return true,val
	end
	return false
end

function banlogin.banacct(acct,exceedtime,reason)
	exceedtime = exceedtime or 2 * 365 * 24 * 3600
	exceedtime = os.time() + exceedtime
	logger.log("info","banlogin",string.format("[banacct] acct=%s exceedtime=%s reason=%s",acct,exceedtime,reason))
	local val = {
		exceedtime = exceedtime,
		reason = reason,
	}
	local db = dbmgr.getdb()
	local key = db:key("banlogin:acct",acct)
	db:set(key,val)
	db:expireat(key,exceedtime)
end

function banlogin.unbanacct(acct,reason)
	local db = dbmgr.getdb()
	local key = db:key("banlogin:acct",acct)
	local isban,val = banlogin.isbanacct(acct)
	if isban then
		logger.log("info","banlogin",string.format("[unbanacct] acct=%s reason=%s",acct,reason))
		db:del(key)
		return val
	end
end

function banlogin.isbanacct(acct)
	local db = dbmgr.getdb()
	local key = db:key("banlogin:acct",acct)
	local val = db:get(key)
	if val then
		return true,val
	end
	return false
end

return banlogin
