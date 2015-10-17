

local function srvlist(agent,query,header,body)
	local id = agent.id
	local gameflag = query.gameflag
	local gameflags = getgameflags()
	local srvlist = {}
	if gameflag then
		if not gameflags[gameflag] then
			return STATUS_GAMEFLAG_ERR
		end
		srvlist = getsrvlist(gameflag)	
	else
		for gameflag,_ in pairs(gameflags) do
			srvlist[gameflag] = getsrvlist(gameflag)
		end
	end
	return STATUS_OK,srvlist
end

return srvlist
