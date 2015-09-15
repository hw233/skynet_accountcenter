require "script.base.init"
require "script.db.dbmgr"
require "script.logger.init"
require "script.console.init"
require "script.acctmgr"
require "script.oscmd.init"
require "script.hotfix.init"

game = game or {}

function game.startgame()
	print("Startgame...")
	console.init()
	logger.init()
	dbmgr.init()
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
