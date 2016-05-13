
local VALID_GAMEFLAGS = getgameflags()

acctmgr = acctmgr or {}

function acctmgr.init()
end

function acctmgr.clear()
end

function acctmgr.loadacct(acct)
	local db = dbmgr.getdb()
	return db:get(db:key("acct",acct))
end

function acctmgr.saveacct(acctobj)
	local acct = acctobj.acct
	local db = dbmgr.getdb()
	db:set(db:key("acct",acct),acctobj)
end

function acctmgr.getacct(acct)
	local acctobj = acctmgr.loadacct(acct)
	return acctobj
end

function acctmgr.addacct(acct,passwd)
	local acctobj = acctmgr.getacct(acct)
	if acctobj then
		return STATUS_ACCT_ALREADY_EXIST
	end
	logger.log("info","acct",string.format("[addacct] acct=%s passwd=%s",acct,passwd))
	local newacct = {
		acct = acct,
		passwd = passwd,
		createtime = os.time(),
		games = {
		},
	}
	acctmgr.saveacct(newacct)
	return STATUS_OK
end

function acctmgr.delacct(acct)
	local acctobj = acctmgr.getacct(acct)
	if acctobj then
		logger.log("info","acct",string.format("[delacct] acct=%s",acct))
		local db = dbmgr.getdb()
		db:del(acct)
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
		local role = acctmgr.getrole(rolelist,roleid)
		if not role then
			local role = {
				roleid = roleid,
				name = name,
				roletype = roletype,
				lv = 0,
				gold = 0,
				createtime = os.time(),
			}
			logger.log("info","acct",format("[addrole] srvname=%s role=%s",srvname,role))
			table.insert(rolelist,role)
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
	local acctobj = acctmgr.getacct(acct)
	if acctobj then
		local game = acctobj.games[gameflag]
		if game then
			local rolelist = game[srvname]
			if rolelist then
				local role = acctmgr.getrole(rolelist,roleid)
				if role then
					logger.log("info","acct",string.format("[delrole] srvname=%s roleid=%s",srvname,roleid))
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

function acctmgr.getrole(rolelist,roleid)
	local role
	for i,v in ipairs(rolelist) do
		if v.roleid == roleid then
			role = v
			break
		end
	end
	return role
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
				if #rolelist >= 5 then
					return STATUS_OVERLIMIT
				end

				logger.log("info","acct",format("[syncrole] gameflag=%s srvname=%s syncdata=%s",gameflag,srvname,syncdata))
				local role = acctmgr.getrole(rolelist,roleid)
				if not role then
					role = {}
				end
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

function acctmgr.genroleid(srvname)
	assert(srvname)
	local db = dbmgr.getdb()
	local key = dbmgr.key("maxroleid",srvname)
	local maxroleid = db.get(key) or 10000
	maxroleid = maxroleid + 1
	db:set(key,maxroleid)
	return maxroleid
end
return acctmgr
