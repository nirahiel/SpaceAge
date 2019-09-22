local sa_enpay = CreateClientConVar("sa_enable_payments", "1", true, false)

local function SA_AnswerGiveQuery(answer,theID,noSC)
	RunConsoleCommand("sa_giverequest",answer,theID)
	if not noSC then gui.EnableScreenClicker(false) end
end

usermessage.Hook("SA_OpenGiveQuery",function(um)
	local to = um:ReadString()
	local amt = SA.AddCommasToInt(um:ReadLong())
	local theID = um:ReadString()
	
	if (not sa_enpay:GetBool()) or gui.ScreenClickerEnabled() then SA_AnswerGiveQuery("deny",theID,true) return end

	gui.EnableScreenClicker(true)
	Derma_Query("Would you like to pay the player \""..to.."\" "..amt.." credits?","Pay Query","Yes", function() SA_AnswerGiveQuery("allow", theID) end, "No", function() SA_AnswerGiveQuery("deny", theID) end)
end)
