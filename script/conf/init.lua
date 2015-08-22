function getsrvlist(gameflag)
	return require("script.conf.srvlist." .. gameflag)
end

function getgameflags()
	return require("script.conf.gameflag")
end
