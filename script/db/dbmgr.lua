dbmgr = dbmgr or {}

function dbmgr.init()
	dbmgr.conns = {}
end

function dbmgr.getdb(srvname)
	local self_srvname = skynet.getenv("srvname")
	srvname = srvname or self_srvname
	assert(srvname == self_srvname) -- 帐号中心暂时只支持连自身数据库
	local conn = dbmgr.conns[srvname]
	if not conn then
		require "script.db.init"
		local conf = {
			host = skynet.getenv("dbip") or "127.0.0.1",
			port = tonumber(skynet.getenv("dbport")) or 6800,
			db = tonumber(skynet.getenv("dbno")) or 0,
			auth = skynet.getenv("dbauth") or "sundream",
		}
		-- 这里会调用阻塞api:skynet.uniqueservice
		conn = cdb.new(conf)
		dbmgr.conns[srvname] = conn
	end
	return conn
end

function dbmgr.shutdown()
	for srvname,conn in pairs(dbmgr.conns) do
		conn:disconnect()
	end
end

return dbmgr
