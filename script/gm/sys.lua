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
	func = load(cmdline,"=(load)","bt")
	local result= func()
	return result
end

--- cmd: hotfix
--- usage: hotfix 模块名...
function gm.hotfix(args)
	for i,modname in ipairs(args) do
		hotfix.hotfix(modname)
	end
end

return gm
