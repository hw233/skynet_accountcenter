require "script.base.init"
require "script.db.dbmgr"
require "script.logger.init"
require "script.console.init"
require "script.acctmgr"
require "script.oscmd.init"
require "script.hotfix.init"
require "script.gm.init"

game = game or {}

function game.startgame()
	print("Startgame...")
	console.init()
	logger.init()
	dbmgr.init()
	acctmgr.init()
	gm.init()
	oscmd.init()
	game.initall = true
	print("Startgame ok")
	logger.log("info","game","startgame")
end

function game.shutdown(reason)
	game.initall = nil
	print("Shutdown")
	logger.log("info","game",string.format("shutdown start,reason=%s",reason))
	dbmgr.shutdown()
	for i,agent in ipairs(__agents) do
		skynet.send(agent,"lua","exec","dbmgr.shutdown()")
	end
	timer.timeout("timer.shutdown",20,function ()

		logger.log("info","game",string.format("shutdown success,reason=%s",reason))
		logger.shutdown()
		os.execute(string.format("cd ../shell/ && sh killserver.sh %s",skynet.getenv("srvname")))
	end)
end

return game
