local cjson = require "cjson"

require "script.logger"

local VALID_GAMEFLAGS = getgameflags()

acctmgr = acctmgr or {}

function acctmgr.init()
	acctmgr.accts = {}
end

function acctmgr.clear()
	for acct,v in pairs(acctmgr.accts) do
		acctmgr.delacct(acct)
	end
end

function acctmgr.loadacct(acct)
	cjson.encode_sparse_array(true)
	local conn = db.getdb("acct")	
	local val = conn:get(acct)
	if val then
		val = cjson.decode(val)
	end
	return val
end

function acctmgr.saveacct(acctobj)
	local acct = acctobj.acct
	cjson.encode_sparse_array(true)
	local conn = db.getdb("acct")
	local val = cjson.encode(acctobj)
	conn:set(acct,val)
end

function acctmgr.getacct(acct)
	local acctobj = acctmgr.accts[acct]
	if not acctobj then
		acctobj = acctmgr.loadacct(acct)
		if acctobj then
			acctmgr.accts[acct] = acctobj
		end
	end
	return acctobj
end

function acctmgr.addacct(acct,passwd)
	local acctobj = acctmgr.getacct(acct)
	if acctobj then
		return STATUS_ACCT_ALREADY_EXIST
	end
	logger.log("info","acct",string.format("addacct,acct=%s passwd=%s",acct,passwd))
	local newacct = {
		acct = acct,
		passwd = passwd,
		createtime = os.time(),
		games = {
		},
	}
	acctmgr.accts[acct] = newacct
	acctmgr.saveacct(newacct)
	return STATUS_OK
end

function acctmgr.delacct(acct)
	local acctobj = acctmgr.getacct(acct)
	if acctobj then
		logger.log("info","acct",string.format("delacct,acct=%s",acct))
		acctmgr.accts[acct] = nil
		local conn = db.getdb("acct")
		conn:del(acct)
		return STATUS_OK
	end
	return STATUS_ACCT_NOEXIST
end

function acctmgr.addrole(acct,gameflag,srvname,role)
	local roleid = assert(role.roleid)
	local name = assert(role.name)
	local roletype = assert(role.roletype)
	if not VALID_GAMEFLAGS[gameflag] then
		return STATUS_GAMEFLAG_ERR
	end
	local srvlist = getsrvlist(gameflag)
	local srv = srvlist[srvname]
	if not srv then
		return STATUS_SRVNAME_ERR
	end
	local acctobj = acctmgr.getacct(acct)
	if acctobj then
		local game = acctobj.games[gameflag]
		if not game then
			game = {}
			acctobj.games[gameflag] = game
		end
		local rolelist = game[srvname]
		if not rolelist then
			rolelist = {}
			game[srvname] = rolelist
		end
		local role = rolelist[roleid]
		if not role then
			local role = {
				roleid = roleid,
				name = name,
				roletype = roletype,
				lv = 0,
				gold = 0,
				createtime = os.time(),
			}
			logger.log("info","acct",format("addrole,srvname=%s role=%s",srvname,role))
			rolelist[roleid] = role
			acctmgr.saveacct(acctobj)
			return STATUS_OK
		else
			return STATUS_ROLE_ALREADY_EXIST
		end
	end
	return STATUS_ACCT_NOEXIST
end

function acctmgr.delrole(acct,gameflag,srvname,roleid)
	if not VALID_GAMEFLAGS[gameflag] then
		return STATUS_GAMEFLAG_ERR
	end
	local srvlist = getsrvlist(gameflag)
	if not srvlist[srvname] then
		return STATUS_SRVNAME_ERR
	end
	local acccobj = acctmgr.getacct(acct)
	if acctobj then
		local game = acctobj.games[gameflag]
		if game then
			local rolelist = game[srvname]
			if rolelist then
				local role = rolelist[roleid]
				if role then
					logger.log("info","acct",string.format("delrole,srvname=%s roleid=%s",srvname,roleid))
					rolelist[roleid] = nil
					acctmgr.saveacct(acctobj)
					return STATUS_OK
				else
					return STATUS_ROLE_NOEXIST
				end
			else
				return STATUS_SRVNAME_NOEXIST
			end
		else
			return STATUS_GAMEFLAG_NOEXIST
		end
	end
	return STATUS_ACCT_NOEXIST
end

local VALID_SYNC = {
	roleid = true,
	name = true,
	lv = true,
	gold = true,
	roletype = true,
}

function acctmgr.syncrole(acct,gameflag,srvname,syncdata)
	if not VALID_GAMEFLAGS[gameflag] then
		return STATUS_GAMEFLAG_ERR
	end
	local srvlist = getsrvlist(gameflag)
	if not srvlist[srvname] then
		return STATUS_SRVNAME_ERR
	end
	local roleid = assert(syncdata.roleid)
	local acctobj = acctmgr.getacct(acct)
	if acctobj then
		local game = acctobj.games[gameflag]
		if game then
			local rolelist = game[srvname]
			if rolelist then
				local role = rolelist[roleid]
				if not role then
					role = {}
					rolelist[roleid] = role
				end
				logger.log("info","acct",format("syncrole,gameflag=%s srvname=%s syncdata=%s",gameflag,srvname,syncdata))
				for k,v in pairs(syncdata) do
					if VALID_SYNC[k] then
						role[k] = v
					end
				end
				acctmgr.saveacct(acctobj)
				return STATUS_OK
			else
				return STATUS_SRVNAME_NOEXIST
			end
		else
			return STATUS_GAMEFLAG_NOEXIST
		end
	end
	return STATUS_ACCT_NOEXIST
end

function acctmgr.getrolelist(acct,gameflag,srvname)
	if not VALID_GAMEFLAGS[gameflag] then
		return STATUS_GAMEFLAG_ERR
	end
	local srvlist = getsrvlist(gameflag)
	if not srvlist[srvname] then
		return STATUS_SRVNAME_ERR
	end
	local acctobj = acctmgr.getacct(acct)
	if acctobj then
		local game = acctobj.games[gameflag]
		if game then
			local rolelist = game[srvname]
			if rolelist then
				return STATUS_OK,rolelist
			else
				return STATUS_OK,{}
			end
		else
			return STATUS_OK,{}
		end
	end
	return STATUS_ACCT_NOEXIST
end

function acctmgr.mergeserver(acct,gameflag,src_srvname,dst_srvname,oldroleid,newroleid)
	if not VALID_GAMEFLAGS[gameflag] then
		return STATUS_GAMEFLAG_ERR
	end
	local srvlist = getsrvlist(gameflag)
	if not srvlist[src_srvname] then
		return STATUS_SRVNAME_ERR
	end
	if not srvlist[dst_srvname] then
		return STATUS_SRVNAME_ERR
	end
	local acctobj = acctmgr.getacct(acct)
	if acctobj then
		local game = acctobj.games[gameflag]
		if game then
			local role
			local rolelist1 = game[src_srvname]
			if rolelist1 then
				role = rolelist1[oldroleid]
				if role then
					rolelist1[oldroleid] = nil
				else
					return STATUS_ROLE_NOEXIST
				end
			else
				return STATUS_ROLE_NOEXIST
			end
			assert(role)
			local rolelist2 = game[dst_srvname]
			if not rolelist2 then
				rolelist2 = {}
				game[dst_srvname] = rolelist2
			end
			logger.log("debug","acct",string.format("mergeserver,account=%s gameflag=%s src_srvname=%s dst_srvname=%s oldroleid=%s newroleid=%s",acct,gameflag,src_srvname,dst_srvname,oldroleid,newroleid))
			role.roleid = newroleid
			rolelist2[newroleid] = role
			acctmgr.saveacct(acctobj)
			return STATUS_OK
		else
			return STATUS_GAMEFLAG_NOEXIST
		end
	end
	return STATUS_ACCT_NOEXIST
end

return acctmgr
