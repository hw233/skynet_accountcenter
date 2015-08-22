require "script.base"
require "script.db"
require "script.logger"
require "script.console"
require "script.acctmgr"
require "script.oscmd"

game = game or {}

function game.startgame()
	console.init()
	logger.init()
	db.init()
	acctmgr.init()
	oscmd.init()
end

function game.gameover()
end

return game
