local cjson = require "cjson"
local skynet = require "skynet"
local httpc = require "http.httpc"


return function ()
	acctmgr.clear()	
	local host = "127.0.0.1:8001"
	local acct = "test_acct@sina.com"
	local passwd = "test_passwd"
	local gameflag = "lushi"
	local srvname = "gamesrv_100"
	local roleid = 10001
	local name = "test_name"
	local roletype = 0
	local url = string.format("/register?acct=%s&passwd=%s&checkpasswd=%s",acct,passwd,passwd)
	local status,body = httpc.get(host,url)
	pprintf("register,status:%d,body:%s",status,body)
	if status == 200 then
		local result,body = unpackbody(body)	
		if result == 0 then
			url = string.format("/createrole?acct=%s&gameflag=%s&srvname=%s&roleid=%s&name=%s",acct,gameflag,srvname,roleid,name)
			local status,body = httpc.get(host,url)
			pprintf("createrole,status:%s,body:%s",status,body)
			if status == 200 then
				local result,body = unpackbody(body)
				if result == 0 then
					url = string.format("/sync?acct=%s&gameflag=%s&srvname=%s&roleid=%s",acct,gameflag,srvname,roleid)
					local body = cjson.encode({
						roleid = roleid,
						name = name,
						roletype = roletype,
						lv = 1,
						gold = 100,
					})
					status,body = httpc.get(host,url,nil,nil,body)
					pprintf("sync,status:%s,body:%s",status,body)
				end
			end
		end
	end
	url = string.format("/login?acct=%s&passwd=%s",acct,passwd)
	status,body = httpc.get(host,url)
	pprintf("login,status:%s,body:%s",status,body)
	url = string.format("/srvlist")
	status,body = httpc.get(host,url)
	pprintf("srvlist,status:%s,body:%s",status,body)
	url = string.format("/srvlist?gameflag=%s",gameflag)
	status,body = httpc.get(host,url)
	pprintf("url:%s,status:%s,body:%s",url,status,body)
	url = string.format("/rolelist?acct=%s&gameflag=%s&srvname=%s",acct,gameflag,srvname)
	status,body = httpc.get(host,url)
	pprintf("rolelist,status:%s,body:%s",status,body)

	-- no exist url
	url = string.format("/noexisturl?key1=value1&key2=value2")
	status,body = httpc.get(host,url)
	pprintf("no exist url,status:%s,body:%s",status,body)
	-- error url fmt
	url = string.format("/login&acct=%spasswd=%s",acct,passwd)
	status,body = httpc.get(host,url)
	pprintf("error url fmt,status:%s,body:%s",status,body)
end
