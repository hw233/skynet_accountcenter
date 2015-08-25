require "script.base"
require "script.db"
require "script.logger"
require "script.console"
require "script.acctmgr"
require "script.oscmd"

game = game or {}

function game.startgame()
	print("Startgame...")
	console.init()
	logger.init()
	db.init()
	acctmgr.init()
	oscmd.init()
	game.initall = true
	print("Startgame ok")
	logger.log("info","game","startgame")
end

function game.shutdown(reason)
	game.initall = nil
	print("Shutdown")
	logger.log("info","game",string.format("shutdown,reason=%s",reason))
end

return game
