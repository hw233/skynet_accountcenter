dbmgr = dbmgr or {}

local conf = {
	accountcenter = {
		host = "127.0.0.1"
		port = 6800,
		auth = "sundream",
		db = 3,
	}
}

function dbmgr.init()
	dbmgr.conns = {}
end

function dbmgr.getdb(flag)
	flag = flag or "accountcenter"
	local c = assert(conf[flag])
	local conn = dbmgr.conns[flag]
	if not conn then
		conn = redis.connect(c)
		dbmgr.conns[flag] = conn
	end
	return conn
end

function dbmgr.shutdown()
	local conns = dbmgr.conns
	dbmgr.conns = {}
	for _,conn in pairs(conns) do
		conn:disconnect()
	end
end

return dbmgr
