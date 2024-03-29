gm = require "script.gm.init"
--- cmd: shutdown
function gm.shutdown(args)
	local reason = args[1] or "gm"
	game.shutdown(reason)
end

function gm.saveall(args)
	game.saveall()
end

--- cmd: runcmd
--- usage: runcmd lua脚本 [是否返回结果]
function gm.runcmd(args)
	local cmdline = args[1]
	local noresult = args[2]
	if not noresult then
		cmdline = "return " .. cmdline
	end
	local func = load(cmdline,"=(load)","bt")
	return func()
end

--- cmd: hotfix
--- usage: hotfix 模块名...
function gm.hotfix(args)
	for i,modname in ipairs(args) do
		hotfix.hotfix(modname)
		for j,agent in ipairs(__agents) do
			local cmd = string.format("hotfix.hotfix(%q)",modname)
			skynet.send(agent,"lua","exec",cmd)
		end
	end
end

return gm
