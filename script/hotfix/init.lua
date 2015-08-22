require "script.skynet"
require "script.logger"

local workdir = skynet.getenv("workdir")
local patten = workdir .. "accountcenter/?.lua;" .. workdir .. "accountcenter/?/init.lua"
local ignore_module = {
	["script.agent"] = true,
	["script.watchdog"] = true,
}

hotfix = {}

function hotfix.hotfix(modname)
	if type(modname) == "table" then
		for k,v in pairs(modname) do
			print(k,v)
		end
	end
	local prefix = "accountcenter."
	if modname:sub(1,#prefix) == prefix then
		modname = modname:sub(#prefix,#modname)
	end
	if modname:sub(1,6) ~= "script" then
		logger.log("warning","hotfix",string.format("cann't hotfix non-script code,module=%s",modname))
		return
	end
	if ignore_module[modname] then
		return
	end
	skynet.cache.clear()
	local chunk,err
	local errlist = {}
	local env = _ENV
	env.__hotfix = nil
	local name = string.gsub(modname,"%.","/")
	for pat in string.gmatch(patten,"[^;]+") do
		local filename = string.gsub(pat,"?",name)
		chunk,err = loadfile(filename,"bt",env)
		if chunk then
			break
		else
			table.insert(errlist,err)
		end
	end
	if not chunk then
		local msg = string.format("hotfix fail,module=%s reason=%s",modname,table.concat(errlist,"\n"))
		logger.log("error","hotfix",msg)
		skynet.error(msg)
		return
	end
	local oldmod = package.loaded[modname]
	local newmod = chunk()
	package.loaded[modname] = newmod
	if type(env.__hotfix) == "function" then
		env.__hotfix(oldmod)
	end
	logger.log("info","hotfix","hotfix " .. modname)
	print ("hotfix " .. modname)
end

return hotfix

