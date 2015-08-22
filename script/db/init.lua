local redis = require "redis"

db = db or {}

local conf = {
	host = "127.0.0.1",
	port = 6800,
	auth = "sundream",
	db = 0,
}

local dbname = {
	acct = 3,
}

function db.getdb(name)
	local conn = db.conns[name]
	if not conn then
		local id = dbname[name]
		conf.db = id
		conn = redis.connect(conf)
		db.conns[name] = conn
	end
	return conn
end

function db.init()
	db.conns = {}
end

function db.shutdown()
	for name,conn in pairs(self.conns) do
		self.conns[name] = nil
		conn:disconnect()
	end
end

return db
