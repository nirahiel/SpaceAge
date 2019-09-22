AddCSLuaFile("autorun/client/cl_sa_givequery.lua")

local RD = nil
local function InitSAFuncs()
	SA_OldHostName = GetConVarString("hostname")
	SA_OldPassWord = GetConVarString("sv_password")
	RD = CAF.GetAddon("Resource Distribution")
end
timer.Simple(0,InitSAFuncs)

function SA_Send_CredSc(ply)
	ply.Credits = math.floor(ply.Credits)
	ply.TotalCredits = math.floor(ply.TotalCredits)
	ply:SetNWInt("Score",ply.TotalCredits)
	net.Start("SA_CreditsScore")
		net.WriteString(ply.Credits)
		net.WriteString(ply.TotalCredits)		
	net.Send(ply)
end

SA_Send_AllInfos = SA_Send_CredSc
SA_Send_Main = SA_Send_CredSc

function convert_table_to_e2_table(tab)
	local newTab = {}
	for k,v in pairs(tab) do
		local ty = string.lower(type(v))
		if ty == "string" then
			newTab["s"..k] = v
		elseif ty == "number" then
			newTab["n"..k] = v
		elseif ty == "entity" then
			newTab["e"..k] = v
		end
	end
	return newTab
end

function PropMoveSlow(ent,endPos,speed)
	if not speed then speed = 20 end
	local entID = ent:EntIndex()
	--timer.Destroy("SA_StopMovement_"..entID)
	timer.Destroy("SA_ControlMovement_"..entID)
	local phys = ent:GetPhysicsObject()
	local startPos = ent:GetPos()
	local diffVec = (endPos - startPos)
	local diffVecN = diffVec:GetNormal()
	local startAngle = ent:GetAngles()
	ent.curVelo = (diffVecN * speed)
	if phys and phys.IsValid and phys:IsValid() then
		phys:EnableMotion(false)
	end
	local timePassed = 0
	local veloTime = diffVec:Length() / speed
	timer.Create("SA_ControlMovement_"..entID,0.01,0,function()
		timePassed = timePassed + 0.01
		local ent = ents.GetByIndex(entID)
		if not (ent and ent.IsValid and ent:IsValid()) then timer.Destroy("SA_ControlMovement_"..entID) return end
		local phys = ent:GetPhysicsObject()
		local shouldBe = startPos + (diffVecN * (speed * timePassed))
		if phys and phys.IsValid and phys:IsValid() then
			phys:EnableMotion(false)
		end		
		ent:SetPos(shouldBe)
		ent:SetAngles(startAngle)
		if shouldBe == endPos or timePassed >= veloTime or shouldBe:Distance(endPos) <= 1 then
			ent:SetPos(endPos)
			timer.Destroy("SA_ControlMovement_"..entID)
		end
	end)
	/*timer.Create("SA_StopMovement_"..entID,veloTime,1,function()
		timer.Destroy("SA_ControlMovement_"..entID)
		if phys and phys.IsValid and phys:IsValid() then
			phys:SetVelocity(Vector(0,0,0))
			phys:EnableMotion(false)
			phys:EnableCollisions(true)
		else
			ent:SetVelocity(ent.curVelo * -1)
		end
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(endPos)
	end)*/
end

function FindFreeAttachPlace(ent,holder)
	if table.HasValue(holder.TouchTable,ent) then return end
	local i = 0
	for i=1,2,1 do
		local tmpX = holder.TouchTable[i]
		if not (tmpX and tmpX.IsValid and tmpX:IsValid()) then return i end
	end
end

function AttachStorage(ent,holder,pos)
	if ent.TouchPos then return false end
	if not (holder:GetModel() == "models/slyfo/sat_rtankstand.mdl") then return false end
	if not (ent:GetModel() == "models/slyfo/sat_resourcetank.mdl") then return false end
	
	local relPos = Vector(0,0,0)
	if pos == 1 then
		relPos = Vector(1.0884,18.9070,21.4414)
	elseif pos == 2 then
		relPos = Vector(1.0199,-18.7096,21.4414)
	else
		return false
	end
	ent:SetAngles(holder:GetAngles())
	ent:SetPos(holder:LocalToWorld(relPos))
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then return true end
	phys:EnableMotion(true)
	phys:Wake()
	return true
end

function RemoveIntersecting(ent,ignoClasses) --ignoClass IS AND MUST ALWAYS BE A TABLE OR NIL!!!!
	if not ignoClasses then ignoClasses = {} end
	--if string.lower(type(ignoClasses)) == "string" then ignoClasses = {ignoClasses,"sa_mining_drill"} end
	local minPos = ent:LocalToWorld(ent:OBBMins())
	local maxPos = ent:LocalToWorld(ent:OBBMaxs())
	table.insert(ignoClasses,"worldspawn")
	table.insert(ignoClasses,"physgun_beam")
	table.insert(ignoClasses,"predicted_viewmodel")
	for k,v in pairs(ents.FindInBox(minPos,maxPos)) do
		local eClass = v:GetClass()
		if v ~= ent and (not table.HasValue(ignoClasses,eClass)) and (not (v:IsWeapon() or v:IsPlayer() or v:IsNPC())) and v:EntIndex() > 0 then
			local eCG = v:GetCollisionGroup()
			if (eCG == COLLISION_GROUP_WORLD and (not v.Autospawned)) or eClass == "sa_crystal" then
				v:Remove()
			end
		end
	end
end

function FindWorldFloor(fromPos,traceIgno,mayNotHit) --traceIgno AND mayNotHit ARE AND MUST ALWAYS BE A TABLE OR NIL!!!!
	if not traceIgno then traceIgno = {} end
	if not mayNotHit then mayNotHit = {} end
	local i = 0
	while true do
		i = i + 1
		local traceData = nil
		traceData = util.QuickTrace(fromPos,Vector(0,0,-2000),traceIgno)
		if traceData.HitWorld then
			return traceData.HitPos
		elseif i > 10 then 
			return
		elseif traceData.HitNonWorld then
			if table.HasValue(mayNotHit,traceData.Entity) then
				return
			end
			table.Add(traceIgno,traceData.Entity)
		else
			return
		end
	end
end

concommand.Add("sa_respawn_crystals",function(ply)
	if ply:GetLevel() < 3 then return end
	local tempMax = SA_MaxCrystalCount
	SA_MaxCrystalCount = 0
	for k,v in pairs(ents.FindByClass("sa_crystal")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("sa_crystaltower")) do
		v.crystalCount = 0
	end
	SA_MaxCrystalCount = tempMax
	for k,v in pairs(ents.FindByClass("sa_crystaltower")) do
		v:AutoSpawn()
	end
	if(ply and ply:IsPlayer()) then
		SystemSendMSG(ply," respawned all tiberium crystals")
	end
end)

function TFormerTerraForm(terent)
	local ply = SA.PP.GetOwner(terent)
	if not (ply and ply:IsValid() and ply:IsPlayer()) then return end
	
	local SB = CAF.GetAddon("Spacebuild")
	if terent.environment.IsProtected or (not terent.environment:IsPlanet()) or terent.environment == SB.GetSpace() then return end
	local RD = CAF.GetAddon("Resource Distribution")
	local energy = RD.GetResourceAmount(terent, "energy")
	local o2 = RD.GetResourceAmount(terent, "oxygen")
	local co2 = RD.GetResourceAmount(terent, "carbon dioxide")
	local dm = RD.GetResourceAmount(terent, "dark matter")
	local tc = RD.GetResourceAmount(terent, "terracrystal")
	local pf = RD.GetResourceAmount(terent, "permafrost")
	local terenv = terent.environment
	local tersbenv = terenv.sbenvironment
	local terair = tersbenv.air
	if(terent.State < 1) then
		terent:SetState(1)
		terent.StateTicks = 1
	end
	if terent.State > 1 then
		if energy < 10000 then
			terent:TurnOff()
			return
		else
			RD.ConsumeResource(terent, "energy", 10000)
		end
	end
	if tc < 10000 then
		if terent.State > 1 then
			terent:ChangeStability(math.random(-30,-10))
			return
		else
			terent:TurnOff()
			return
		end
	else
		RD.ConsumeResource(terent, "terracrystal", 10000)
	end
	if terent.State == 1 then --Boot up sequence
		if terent.StateTicks > 10 then
			terent:SetState(2)
		else
			if energy < 100000 then
				terent:TurnOff()
				return
			else
				RD.ConsumeResource(terent, "energy", 100000)
			end
		end
	elseif terent.State == 2 then --Gravity adaption
		if tersbenv.gravity > 1.1 then
			tersbenv.gravity = tersbenv.gravity - 0.1
		elseif tersbenv.gravity < 0.9 then
			tersbenv.gravity = tersbenv.gravity + 0.1
		else
			tersbenv.gravity = 1
			terent:SetState(3)
		end
	elseif terent.State == 3 then --Pressure adaption
		if tersbenv.pressure > 1.1 then
			tersbenv.pressure = tersbenv.pressure - 0.1
		elseif tersbenv.pressure < 0.9 then
			tersbenv.pressure = tersbenv.pressure + 0.1
		else
			tersbenv.pressure = 1
			terent:SetState(4)
		end
		tersbenv.atmosphere = tersbenv.pressure
	elseif terent.State == 4 then --We need to make sure the planet is terraformable (temperature 1 adaption)
		local tempe = tersbenv.temperature + (( tersbenv.temperature * ((terenv:GetCO2Percentage() - terair.co2per)/100))/2)
		local tvalid = true
		if tempe > 295 then
			tempe = tersbenv.temperature + (( tersbenv.temperature * ((0 - terair.co2per)/100))/2) --Try what would happen without CO2
			if tempe > 295 then --Nah, not enough :/
				if pf < 1000 then
					terent:ChangeStability(math.random(-30,-10))
					return
				end
				RD.ConsumeResource(terent, "permafrost", 1000)
				terair.temperature = terair.temperature - 1
				tvalid = false
			end
		elseif tempe < 288 then
			tempe = tersbenv.temperature + (( tersbenv.temperature * ((80 - terair.co2per)/100))/2) --Try what would happen with nearly full CO2
			if tempe < 288 then --Nah, not enough :/
				if dm < 1000 then
					terent:ChangeStability(math.random(-30,-10))
					return
				end
				RD.ConsumeResource(terent, "dark matter", 1000)
				tersbenv.temperature = tersbenv.temperature + 1
				tvalid = false
			end		
		end
		if tvalid then
			terent:SetState(5)
		end
	elseif terent.State == 5 then --Adapt temp2 to temp1
		local tDiff = tersbenv.temperature2 - tersbenv.temperature
		local tvalid = true
		if tDiff > 1 then
			if pf < 1000 then
				terent:ChangeStability(math.random(-30,-10))
				return
			end
			RD.ConsumeResource(terent, "permafrost", 1000)
			tersbenv.temperature2 = tersbenv.temperature2 - 1
			tvalid = false
		elseif tDiff < -1 then
			if dm < 1000 then
				terent:ChangeStability(math.random(-30,-10))
				return
			end
			RD.ConsumeResource(terent, "dark matter", 1000)
			tersbenv.temperature2 = tersbenv.temperature2 + 1
			tvalid = false
		else
			tersbenv.temperature2  = tersbenv.temperature
		end
		if tvalid then
			terent:SetState(6)
		end
	elseif terent.State == 6 then --The actual terraforming
		local avalid = true
		if (terair.o2 / terair.max) < 0.10 then
			if o2 < 10000 then
				terent:ChangeStability(math.random(-30,-10))
				return				
			end
			TFormerPushAtmo(terent,"oxygen","o2",10000)
			avalid = false
		end
		local ttemp = terenv:GetTemperature(terent)
		if ttemp < 288 then
			TFormerPushAtmo(terent,"carbon dioxide","co2",10000)
			avalid = false
		elseif ttemp > 295 then
			if terair.co2 > 10000 then
				terair.co2 = terair.co2 - 10000
				terair.empty = terair.empty + 10000
			else
				terair.empty = terair.empty + terair.co2
				terair.co2 =  0
			end
			avalid = false
		end
		if avalid then
			terent:SetState(7)
		end
	elseif terent.State > 6 then
		terent:TurnOff()
		return
	end
end

function TFormerPushAtmo(terent,resName,atmoname,amount)
	RD.ConsumeResource(terent,resName,amount)
	local terair = terent.environment.sbenvironment.air
	if terair.empty < amount then
		local neededAm = amount - terair.empty
		terair.empty = 0
		if terair.n > 0 then
			if terair.n > neededAm then
				terair.n = terair.n - neededAm
				neededAm = 0
			else
				neededAm = neededAm - terair.n
				terair.n = 0
			end
		end
		if neededAm > 0 and terair.h > 0 then
			if terair.h > neededAm then
				terair.h = terair.h - neededAm
				neededAm = 0
			else
				neededAm = neededAm - terair.h
				terair.h = 0
			end
		end
		if atmoname ~= "co2" and neededAm > 0 and (terair.co2 / terair.max) > 0.80 then
			if terair.co2 > neededAm then
				terair.co2 = terair.co2 - neededAm
				neededAm = 0
			end
		end
		if atmoname ~= "o2" and neededAm > 0 and (terair.o2 / terair.max) > 0.10 then
			if terair.o2 > neededAm then
				terair.o2 = terair.o2 - neededAm
				neededAm = 0
			end
		end
		amount = amount - neededAm
	else
		terair.empty = terair.empty - amount
	end
	terair[atmoname] = terair[atmoname] + amount
end

function TFormerSpazzOut(terent,forcekill)
	local SB = CAF.GetAddon("Spacebuild")
	if terent.FinalSpazzed or terent.environment.IsProtected or (not terent.environment:IsPlanet()) or terent.environment == SB.GetSpace() then return end
	local energy = RD.GetResourceAmount(terent, "energy")
	if terent.State ~= -1 then
		local o2 = RD.GetResourceAmount(terent, "oxygen")
		local co2 = RD.GetResourceAmount(terent, "carbon dioxide")
		local dm = RD.GetResourceAmount(terent, "dark matter")
		local tc = RD.GetResourceAmount(terent, "terracrystal")
		local pf = RD.GetResourceAmount(terent, "permafrost")
		if o2 > 0 then RD.ConsumeResource(terent, "oxygen", o2) end
		if co2 > 0 then RD.ConsumeResource(terent, "carbon dioxide", co2) end
		if dm > 0 then RD.ConsumeResource(terent, "dark matter", dm) end
		if tc > 0 then RD.ConsumeResource(terent, "terracrystal", tc) end
		if pf > 0 then RD.ConsumeResource(terent, "permafrost", pf) end
	end
	terent:SetState(-1)
	if energy < 10000 then
		terent:TurnOff()
		return
	else	
		RD.ConsumeResource(terent, "energy", 10000)
	end
	local haschanged = false
	local myenv = terent.environment.sbenvironment
	local envair = myenv.air
	terent:ChangeStability(math.random(-50,-30))
	for k,v in pairs(envair) do
		if string.Right(k,3) == "per" or k == "empty" or k == "max" then
			--Do nothing
		elseif v > 5000000 then
			envair[k] = v - 5000000
			envair["empty"] = envair["empty"] + 5000000
			haschanged = true
		else
			envair["empty"] = envair["empty"] + envair[k]
			envair[k] = 0
		end
	end
	if myenv.temperature >= 25 then
		myenv.temperature = myenv.temperature - 25
		haschanged = true
	else
		myenv.temperature = 0
	end
	if myenv.temperature2 >= 25 then
		myenv.temperature2 = myenv.temperature2 - 25
		haschanged = true
	else
		myenv.temperature2 = 0
	end	
	if (not haschanged) or forcekill then
		terent.FinalSpazzed = true
		if math.random(0,1) > 0.5 then
			myenv.temperature = math.random(400,1200)
			myenv.temperature2 = math.random(400,1200)
		else
			myenv.temperature = math.random(10,200)
			myenv.temperature2 = math.random(10,200)
		end
		if(myenv.temperature2 < myenv.temperature) then
			myenv.temperature2 = myenv.temperature + 10
		end
		local leftair = envair.max
		local lastval = math.random(0,leftair)
		envair.h = lastval
		leftair = leftair - lastval
		lastval = math.random(0,leftair)
		envair.n = lastval
		leftair = leftair - lastval
		lastval = math.random(0,leftair)
		envair.co2 = lastval
		leftair = leftair - lastval
		--lastval = math.random(0,leftair)
		--envair.o2 = lastval
		--leftair = leftair - lastval
		envair.empty = leftair
		leftair = 0
		if not forcekill then
			local vPoint = terent:GetPos() 
			local effectdata = EffectData() 
			effectdata:SetStart( vPoint )
			effectdata:SetOrigin( vPoint ) 
			effectdata:SetScale( 2300 ) 
			effectdata:SetMagnitude( 1 )
			util.Effect( "warpcore_breach", effectdata )
			local shake = ents.Create("env_shake")
			shake:SetKeyValue("amplitude", "16")
			shake:SetKeyValue("duration", "6")
			shake:SetKeyValue("radius", 1) 
			shake:SetKeyValue("spawnflags", 5) 
			shake:SetKeyValue("frequency", "240")
			shake:SetPos(vPoint)
			shake:Spawn()
			shake:Fire("StartShake","","0.6")
			shake:Fire("kill","","8")
			terent:EmitSound( "explode_9" )
			for k,v in pairs(ents.GetAll()) do
				if not v.Autospawned and not v.CDSIgnore and v.environment == terent.environment then
					if v:IsPlayer() or v:IsNPC() then
						v:Kill()
					elseif v:IsVehicle() then
						local vD = v:GetPassenger()
						if(vD and vD:IsValid() and (vD:IsPlayer() or vD:IsNPC())) then
							vD:Kill()
						end
						local vD = v:GetDriver()
						if(vD and vD:IsValid() and (vD:IsPlayer() or vD:IsNPC())) then
							vD:Kill()
						end
						v:Remove()
					else
						v:Remove()
					end
				end
			end
			terent:Remove()
		end
	elseif not forcekill then
		TFormerSparks(terent)
		timer.Simple(0.1,TFormerSparks,terent)
		timer.Simple(0.2,TFormerSparks,terent)
		timer.Simple(0.3,TFormerSparks,terent)
		timer.Simple(0.4,TFormerSparks,terent)
		timer.Simple(0.5,TFormerSparks,terent)
		timer.Simple(0.6,TFormerSparks,terent)
		timer.Simple(0.7,TFormerSparks,terent)
		timer.Simple(0.8,TFormerSparks,terent)
		timer.Simple(0.9,TFormerSparks,terent)
		TFormerExplosion(terent)
		timer.Simple(0.5,TFormerExplosion,terent)
	end
	local ply = SA.PP.GetOwner(terent)
	if not (ply and ply:IsValid() and ply:IsPlayer()) then return end
end

function TFormerExplosion(terent)
		local OBBMins = terent:OBBMins() 
		local OBBMaxs = terent:OBBMaxs()
		local vPoint = terent:LocalToWorld(Vector(math.random(OBBMins.x,OBBMaxs.x),math.random(OBBMins.y,OBBMaxs.y),math.random(OBBMins.z,OBBMaxs.z)))
		local effectdata = EffectData() 
		effectdata:SetStart( vPoint )
		effectdata:SetOrigin( vPoint ) 
		effectdata:SetScale( 1 ) 
		effectdata:SetMagnitude( 1 )
		util.Effect( "Explosion", effectdata )
end

function TFormerSparks(terent)
		local Rep = ents.Create("point_tesla")
		Rep:SetKeyValue("targetname", "teslab")
		Rep:SetKeyValue("m_SoundName", "DoSpark")
		Rep:SetKeyValue("texture", "sprites/physbeam.spr")
		Rep:SetKeyValue("m_Color", "200 200 255")
		Rep:SetKeyValue("m_flRadius", 1000)
		Rep:SetKeyValue("beamcount_min", 2)
		Rep:SetKeyValue("beamcount_max", 5)
		Rep:SetKeyValue("thick_min", 2)
		Rep:SetKeyValue("thick_max", 8)
		Rep:SetKeyValue("lifetime_min", "0.1")
		Rep:SetKeyValue("lifetime_max", "0.2")
		Rep:SetKeyValue("interval_min", "0.05")
		Rep:SetKeyValue("interval_max", "0.08")
		local OBBMid = terent:OBBCenter()
		local OBBMax = terent:OBBMaxs()
		local SparPos = terent:LocalToWorld(Vector(OBBMid.x, OBBMid.y, OBBMax.z))
		Rep:SetPos(SparPos)
		Rep:Spawn()
		Rep:Fire("DoSpark","",0)
		Rep:Fire("kill","", 1)
end

function Discharge(ent)
	local RD = CAF.GetAddon("Resource Distribution")
	local amount = 0
	local Pos = ent:GetPos()
	local Ang = ent:GetAngles()
	local trace = {}
	trace.start = Pos+(Ang:Up()*ent:OBBMaxs().z)
	trace.endpos = Pos+(Ang:Up()*ent.beamlength)
	trace.filter = { ent }
	local tr = util.TraceLine( trace )
	if (tr.Hit) then
		local hitent = tr.Entity
		if hitent.IsAsteroid then
			MineThing(ent,hitent,"ore")
		elseif hitent.IsOreStorage and GetConVar("sa_pirating"):GetBool() then
			local resLeft = RD.GetResourceAmount(hitent, "ore")
			local toUse = math.floor(ent.yield * 1.5)
			if(resLeft < toUse) then toUse = resLeft end
			RD.ConsumeResource(hitent,"ore",toUse)
			RD.SupplyResource(ent, "ore", math.floor(toUse * 0.9))
		elseif hitent:IsPlayer() then
			hitent:TakeDamage(25,ent,ent)
		end		
	end
end

function MineThing(ent,hitent,resType)
	local own = SA.PP.GetOwner(ent)
	if own and own.IsAFK then return end
	if (hitent.health > 0) then
		if (hitent.health < ent.damage) then 
			amount = math.floor(ent.yield * (hitent.health / ent.damage))
			hitent:Remove()
		else
			amount = ent.yield
		end
		RD.SupplyResource(ent, resType, amount)
		hitent.health = hitent.health - ent.damage
	else
		hitent:Remove()
	end	
end


function DestroyConstraints( Ent1, Ent2, Bone1, Bone2, cType )
	if ( !constraint.CanConstrain( Ent1, Bone1 ) ) then return false end
	if ( !constraint.CanConstrain( Ent2, Bone2 ) ) then return false end

	local Phys1 = Ent1:GetPhysicsObjectNum( Bone1 )
	local Phys2 = Ent2:GetPhysicsObjectNum( Bone2)
	
	if ( Phys1 == Phys2 ) then return false end
	
	if ( !Ent1:GetTable().Constraints and !Ent2:GetTable().Constraints ) then return end
	if ( !Ent1:GetTable().Constraints ) then -- If our Ent1 is the world, we can't get a constraint table, so switch the entities and look through them that way
		local thirdEnt
		thirdEnt = Ent1
		Ent1 = Ent2
		Ent2 = thirdEnt
	end 
	  
	// Next, run through all of the constraints on the entity
	// There's already a function for this, but it doesn't
	// really take into account choosing the world first
	for k, v in pairs( Ent1:GetTable().Constraints ) do
 
		if ( v:IsValid() ) then -- Continues if it finds a valid constraint
	
			local CTab = v:GetTable() -- Variableizes all of the attributes of the individual constraint
 
			if ( CTab.Type == cType and CTab.Ent1 == Ent1 and CTab.Ent2 == Ent2 and CTab.Bone1 == Bone1 and CTab.Bone2 == Bone2 ) or  ( CTab.Type == cType and CTab.Ent1 == Ent2 and CTab.Ent2 == Ent1 and CTab.Bone1 == Bone2 and CTab.Bone2 == Bone1 ) then

				foundConstraint = v -- We've found the constraint we want to destroy
				
			end
		end
	end 

	if !foundConstraint then return false end
	foundConstraint:Remove()
	foundConstraint = nil
	
	return true
end

local bor = bit.bor
local blshift = bit.lshift
local ENT = FindMetaTable("Entity")
function ENT:SetNetworkedColor(name, c)
	local n = bor(c.r, blshift(c.g, 8), blshift(c.b, 16), 255)
    self:SetNetworkedInt(name, n)
end
