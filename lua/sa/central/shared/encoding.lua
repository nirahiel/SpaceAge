SA.REQIORE("central.core")
SA.REQUIRE("central.enums")

local function TranslateObjectToCentral(element)
	if not element then
		return {
			type = Sa.Central.TYPE_NIL,
		}
	end

	if element.type then
		return element
	end

	if element.IsPlayer and element:IsPlayer() then
		return {
			type = SA.Central.TYPE_PLAYER,
			name = element:GetName(),
			team = element:Team(),
			alive = element:Alive(),
			color = team.GetColor(element:Team()),
		}
	end

	if element.r and element.g and element.b and element.a then
		return {
			type = SA.Central.TYPE_COLOR,
			r = element.r,
			g = element.g,
			b = element.b,
			a = element.a,
		}
	end

	return {
		type = SA.Central.TYPE_TEXT,
		text = tostring(element),
	}
end

SA.Central.TranslateObjectToCentral = TranslateObjectToCentral

local function WriteMessageElement(ele)
	if not ele then
		net.WriteUInt(SA.Central.TYPE_NIL, 8)
		return
	end

	if not ele.type then
		ele = TranslateObjectToCentral(ele)
	end

	net.WriteUInt(ele.type, 8)
	if ele.type == SA.Central.TYPE_NIL then
		return
	end

	if ele.type == SA.Central.TYPE_TEXT then
		net.WriteString(ele.text)
		return
	end

	if ele.type == SA.Central.TYPE_COLOR then
		net.WriteColor(Color(ele.r, ele.g, ele.b, ele.a))
		return
	end

	if ele.type == SA.Central.TYPE_PLAYER then
		net.WriteString(ele.name)
		net.WriteUInt(ele.team, 8)
		net.WriteBool(ele.alive)
		net.WriteColor(Color(ele.color.r, ele.color.g, ele.color.b, ele.color.a))
		return
	end
end

SA.Central.WriteMessageElement = WriteMessageElement
