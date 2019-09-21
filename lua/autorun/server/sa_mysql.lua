require("mysqloolib")

MySQL = {}
local db = mysqloo.CreateDatabase("127.0.0.1", "spaceage", "spaceage", "spaceage")

-- (data, isok, merror, ply, sid)
local function makecb(cb, ...)
	if not cb then
		return nil
	end

	local args = {...}
	return function(query, status, dataOrError)
		if status then
			cb(dataOrError, true, nil, unpack(args))
		else
			cb(nil, false, dataOrError, unpack(args))
		end
	end
end

function MySQL:Query(query, cb, ...)
	return db:RunQuery(query, makecb(cb, ...))
end

function MySQL:Escape(str)
	return db:escape(str)
end
