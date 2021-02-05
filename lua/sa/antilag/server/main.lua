local timeDiffLast = SysTime() - CurTime()
local lastLag = 0
local lagTicks = 0

local convarDelta = CreateConVar("sa_antilag_mindelta", 0.05)
local convarTimeout = CreateConVar("sa_antilag_timeout", 10)
local convarWarning = CreateConVar("sa_antilag_warning", 5)
local convarCritical = CreateConVar("sa_antilag_critical", 50)

local function HookDisableIfWarning(ply)
	if lagTicks < convarWarning:GetInt() then return end
	if IsValid(ply) and ply:IsPlayer() then
		if ply:IsAdmin() then
			return
		end
		ply:ChatPrint("You cannot do this during server lag!")
	end
	return false
end

local function HookDisableIfCritical(ply)
	if lagTicks < convarCritical:GetInt() then return end
	if IsValid(ply) and ply:IsPlayer() then
		if ply:IsAdmin() then
			return
		end
		ply:ChatPrint("You cannot do this during extreme server lag!")
	end
	return false
end

local function HookAddDisableIfCritical(name)
	hook.Add(name, "SA_AntiLag_" .. name, HookDisableIfCritical)
end

local function HookAddDisableIfWarning(name)
	hook.Add(name, "SA_AntiLag_" .. name, HookDisableIfWarning)
end

local function SendAll(msg)
	msg = "[AntiLag] " .. msg
	print(msg)
	for _, ply in pairs(player.GetAll()) do
		ply:ChatPrint(msg)
	end
end

hook.Add("Tick", "SA_AntiLag_Think", function()
	local sysTime = SysTime()
	local timeDiff = sysTime - CurTime()
	local timeDiffDelta = timeDiff - timeDiffLast
	timeDiffLast = timeDiff

	if lagTicks > 0 and sysTime - lastLag > convarTimeout:GetFloat() then
		if lagTicks > convarWarning:GetInt() then
			SendAll("Normalized! All restrictions lifted!")
			hook.Run("SA_AntiLagReturnNormal")
		end
		lagTicks = 0
		print("Lag tick", lagTicks)
	end

	if timeDiffDelta > convarDelta:GetFloat() then
		lagTicks = lagTicks + 1
		lastLag = sysTime
		print("Lag tick", lagTicks, timeDiffDelta)

		if lagTicks == convarWarning:GetInt() then
			SendAll("warning! Disabling prop spawning and physgun reload!")
			hook.Run("SA_AntiLagEnterWarning")
		elseif lagTicks == convarCritical:GetInt() then
			SendAll("Critical! Disabling toolgun and physgun use!")
			hook.Run("SA_AntiLagEnterCritical")
		end
	end
end)

HookAddDisableIfWarning("PlayerSpawnObject")
HookAddDisableIfWarning("PhysgunReload")
HookAddDisableIfCritical("CanTool")
HookAddDisableIfCritical("PhysgunPickup")

hook.Add("SA_AntiLagEnterCritical", "SA_AntiLag_FreezeAll", function()
	for _, ent in pairs(ents.GetAll()) do
		if not IsValid(ent) then
			continue
		end
		if ent:IsPlayer() or ent:IsNPC() then
			continue
		end
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
	SendAll("Froze all props!")
end)
