--glualint:ignore-file
E2Lib.RegisterExtension("sa_money", false)

local bool_to_number = SA.bool_to_number

local lastMoneyFunc = {}

local moneyResults = {}

local function callMoneyFunc(ply)
	local plyID = ply:SteamID()
	local theTime = CurTime()
	if (not lastMoneyFunc[plyID]) or lastMoneyFunc[plyID] < (theTime - 2) then
		lastMoneyFunc[plyID] = theTime
		return true
	end
	return false
end

local function callMyselfGive(self, resultTable, allowed)
	if (self and self.entity and self.entity.Execute) then
		moneyResults = {}
		moneyResults.from = resultTable[1]
		moneyResults.amount = resultTable[3]
		moneyResults.allowed = bool_to_number(allowed)
		self.entity:Execute()
		moneyResults = {}
	end
end

__e2setcost(50)
e2function number entity:giveCredits(amount)
	if not (callMoneyFunc(self.player) and this and IsValid(this) and this:IsPlayer()) then return 0 end
	return bool_to_number(SA.GiveCredits.Do(self.player, this, amount))
end

e2function number entity:payCredits(amount)
	if not (callMoneyFunc(self.player) and this and IsValid(this) and this:IsPlayer()) then return 0 end
	return bool_to_number(SA.GiveCredits.Confirm(this, self.player, amount,
		function(resultTable, allowed)
			callMyselfGive(self, resultTable, allowed)
		end)
	)
end

__e2setcost(10)
e2function number entity:credits()
	if not (this and IsValid(this) and this:IsPlayer() and this.sa_data.credits) then return -1 end
	return this.sa_data.credits
end

__e2setcost(10)
e2function number entity:score()
	if not (this and IsValid(this) and this:IsPlayer() and this.sa_data.score) then return -1 end
	return this.sa_data.score
end

e2function number credits()
	return self.player.sa_data.credits
end

e2function number score()
	return self.player.sa_data.score
end

__e2setcost(1)
e2function entity payGetFrom()
	if (moneyResults.from == nil) then
		return nil
	end
	return moneyResults.from
end
e2function number payGetAmount()
	if (moneyResults.amount == nil) then
		return 0
	end
	return moneyResults.amount
end
e2function number payGetAllowed()
	if (moneyResults.allowed == nil) then
		return 0
	end
	return moneyResults.allowed
end
e2function number payClk()
	return bool_to_number(table.Count(moneyResults) > 0)
end
