--print(package.path)
require "script.game"

local skynet = require "skynet"
local socket = require "socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"

__agents = __agents or {}

skynet.start(function ()
	local id = socket.listen("0.0.0.0",6000)
	local agentnum = tonumber(skynet.getenv("agentnum")) or 20
	local servicename = "script/agent"
	for i=1,agentnum do
		__agents[i] = skynet.newservice(servicename)
	end
	local balance = 0
	socket.start(id,function (id,addr)
		balance = balance + 1
		if balance > agentnum then
			balance = 1
		end
		skynet.send(__agents[balance],"lua","start",id,addr)
	end)

	game.startgame()
end)
