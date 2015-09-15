dbmgr = dbmgr or {}

local conf = {
	host = "127.0.0.1",
	port = 6800,
	auth = "sundream",
	db = 3,
}

function dbmgr.init()
	dbmgr.conns = {}
end

function dbmgr.getdb(srvname)
	srvname = srvname or skynet.getenv("srvname")
	local conn = dbmgr.conns[srvname]
	if not conn then
		require "script.db.init"
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
