local workdir = skynet.getenv("workdir")
local patten = workdir .. "/?.lua;"
local ignore_module = {
	"script%.init",
	"script%.agent",
	"script%.watchdog",
}

hotfix = hotfix or {}

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
		logger.log("warning","hotfix",string.format("[cann't hotfix non-script code] module=%s",modname))
		return
	end
	if modname:sub(-4,-1) == ".lua" then
		modname = modname:sub(1,-5)
	end
	for i,patten in ipairs(ignore_module) do
		if modname == string.match(modname,patten) then
			return
		end
	end
	modname = string.gsub(modname,"/",".")
	modname = string.gsub(modname,"\\",".")
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
		local msg = string.format("%s hotfix fail,module=%s reason=%s",SERVICE_NAME,modname,table.concat(errlist,"\n"))
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
	local msg = string.format("%s hotfix %s",SERVICE_NAME,modname)
	logger.log("info","hotfix",msg)
	print(msg)
end

return hotfix

