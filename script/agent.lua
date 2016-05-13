require "script.game"
local skynet = require "skynet"
local socket = require "socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"

local function __onconnect(id,addr)
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
					local isok,status,result = xpcall(func,onerror,agent,query,header,body)
					logger.log("debug","request",format("url=%s isok=%s status=%s result=%s",url,isok,status,result))
					if not isok then
						skynet.error(string.format("exec %s,status=%s result=%s",url,status,result))
						response(id,500)
					else
						if status ~= NO_RESPONSE then
							response(id,200,packbody(status,result))
						end
					end
				else
					--skynet.error(func)
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

local function rpc(cmd,...)
	logger.log("info","agentcmd","rpc",cmd,...)
	cmd = "return " .. cmd
	local chunk = load(cmd,"=(load)","bt",_G)
	local func = chunk()
	if type(func) ~= "function" then
		return func
	else
		return func(...)
	end
end

local function exec(cmd)
	logger.log("info","agentcmd","exec",cmd)
	local chunk = load(cmd,"=(load)","bt",_G)
	if chunk then
		chunk()
	end
end

skynet.start(function ()
	skynet.dispatch("lua",function (session,source,cmd,...)
		if cmd == "start" then
			__onconnect(...)
		elseif cmd == "rpc" then
			skynet.retpack(rpc(cmd,...))
		elseif cmd == "exec" then
			exec(...)
		end
	end)
	dbmgr.init()
end)



