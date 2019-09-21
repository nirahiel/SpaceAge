require("mysqloolib")

MySQL = {}
local db = mysqloo.CreateDatabase("localhost", "root", "root", "spaceage")

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
