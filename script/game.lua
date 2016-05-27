require "script.base.init"
require "script.db.dbmgr"
require "script.logger.init"
require "script.console.init"
require "script.acctmgr"
require "script.oscmd.init"
require "script.hotfix.init"
require "script.gm.init"
require "script.banlogin"

local function _print(...)
	print(...)
	skynet.error(...)
end

game = game or {}

function game.startgame()
	print("Startgame...")
	console.init()
	_print("console.init")
	logger.init()
	_print("logger.init")
	dbmgr.init()
	_print("dbmgr.init")
	acctmgr.init()
	_print("acctmgr.init")
	gm.init()
	_print("gm.init")
	oscmd.init()
	_print("oscmd.init")
	game.initall = true
	_print("Startgame ok")
	logger.log("info","game","[startgame]")
end

function game.shutdown(reason)
	game.initall = nil
	_print("Shutdown")
	logger.log("info","game",string.format("[shutdown start] reason=%s",reason))
	dbmgr.shutdown()
	_print("dbmgr.shutdown")
	for i,agent in ipairs(__agents) do
		skynet.send(agent,"lua","exec","dbmgr.shutdown()")
	end
	timer.timeout("timer.shutdown",20,function ()
		_print("logger.shutdown")

		logger.log("info","game",string.format("[shutdown success] reason=%s",reason))
		logger.shutdown()
		_print("Shutdown ok")
		os.execute(string.format("cd ../shell/ && sh killserver.sh %s",skynet.getenv("srvname")))
	end)
end

return game
