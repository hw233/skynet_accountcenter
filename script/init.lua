--print(package.path)
require "script.game"
require "script.db"


local skynet = require "skynet"
local socket = require "socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local table = table
local string = string

function __onconnect(id,addr)
	local agent = {
		id = id,
		addr = addr,
	}
	skynet.error(string.format("connected,id:%s,addr:%s",id,addr))
	socket.start(id)
	local code,url,method,header,body = httpd.read_request(sockethelper.readfunc(id),8192)
	if code then
		if code ~= 200 then
			response(id,code)
		else
			local resp = ""
			if method == "GET" then
				local path,query = urllib.parse(url)	
				local modname = "script/root" .. path
				local modname = modname:gsub("/",".")
				local isok,func = pcall(require,modname)
				if isok then
					query = query and urllib.parse_query(query)
					--local isok,status,extra = pcall(func,agent,query,header,body)
					local isok,status,extra = xpcall(func,onerror,agent,query,header,body)
					logger.log("debug","request",format("url=%s isok=%s status=%s extra=%s",url,isok,status,extra))
					if not isok then
						skynet.error(string.format("exec %s,status=%s extra=%s",url,status,extra))
						response(id,500)
					else
						response(id,200,packbody(status,extra))
					end
				else
					skynet.error(func)
					response(id,404)
				end
			elseif method == "POST" then
			end
		end
	else
		if url == sockethelper.socket_error then
			skynet.error("socket closed")
		else
			skynet.error(url)
		end
	end
	socket.close(id)
end

skynet.start(function ()
	--local id = socket.listen("0.0.0.0",8001)
	local id = socket.listen("127.0.0.1",8001)
	socket.start(id,__onconnect)
	game.startgame()
end)
	
