if AbilityMarisa == nil then
	AbilityMarisa = class({})
end

function OnMarisa01SpellStart(keys)
	AbilityMarisa:OnMarisa01Start(keys)
end

function OnMarisa01SpellMove(keys)
	AbilityMarisa:OnMarisa01Move(keys)
end

function OnMarisa02SpellStart(keys)
	AbilityMarisa:OnMarisa02Start(keys)
end
function OnMarisa02SpellDamage(keys)
	AbilityMarisa:OnMarisa02Damage(keys)
end
function OnMarisa02SpellRemove(keys)
	--[[local caster = EntIndexToHScript(keys.caster_entindex)
	local unitIndex = keys.ability:GetContext("ability_marisa02_effectUnit")
	local unit = EntIndexToHScript(unitIndex)
	if(unit~=nil)then
		Timer.Wait 'ability_marisa02_effectUnit_release' (0.5,
			function()
				if(unit~=nil)then
					unit:RemoveSelf()
				end
			end
	    )
	end]]--
end

function OnMarisa03SpellStart(keys)
	AbilityMarisa:OnMarisa03Start(keys)
end

function OnMarisa03SpellThink(keys)
	AbilityMarisa:OnMarisa03Think(keys)
end

function OnMarisa03DealDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)

	local damage_table = {
		victim = keys.unit,
		attacker = caster.hero,
		damage = keys.DealDamage,
		damage_type = keys.ability:GetAbilityDamageType(), 
	    damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	UnitDamageTarget(damage_table) 
end

function OnMarisa04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	--[[local forwardVector = caster:GetOrigin()+caster:GetForwardVector()*1000
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/chen_cast_4.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin()+Vector(0,0,64))
	ParticleManager:SetParticleControl(effectIndex, 1, forwardVector)]]--

	local unit = CreateUnitByName(
		"npc_dota2x_unit_marisa04_spark"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	caster.effectcircle = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_04_spark_circle.vpcf", PATTACH_CUSTOMORIGIN, unit)
	caster.effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_04_spark.vpcf", PATTACH_CUSTOMORIGIN, unit)
	caster.effectIndex_b = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_04_spark_wind_b.vpcf", PATTACH_CUSTOMORIGIN, unit)
	keys.ability:SetContextNum("ability_marisa_04_spark_unit",unit:GetEntityIndex(),0)

	MarisaSparkParticleControl(caster,targetPoint,keys.ability)
	keys.ability:SetContextNum("ability_marisa_04_spark_lock",FALSE,0)
end

function MarisaSparkParticleControl(caster,targetPoint,ability)
	local unitIndex = ability:GetContext("ability_marisa_04_spark_unit")
	local unit = EntIndexToHScript(unitIndex)

	if(caster.targetPoint == targetPoint)then
		return
	else
		caster.targetPoint = targetPoint
	end

	if(caster.effectIndex_b ~= -1)then
		ParticleManager:DestroyParticleSystem(caster.effectIndex_b,true)
	end

	if(unit == nil or caster.effectIndex == -1 or caster.effectcircle == -1)then
		print(unit)
		print(caster.effectIndex)
		print(caster.effectcircle)
		return
	end

	caster.effectIndex_b = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_04_spark_wind_b.vpcf", PATTACH_CUSTOMORIGIN, unit)

	forwardRad = GetRadBetweenTwoVec2D(targetPoint,caster:GetOrigin()) 
	vecForward = Vector(math.cos(math.pi/2 + forwardRad),math.sin(math.pi/2 + forwardRad),0)
	unit:SetForwardVector(vecForward)
	vecUnit = caster:GetOrigin() + Vector(caster:GetForwardVector().x * 100,caster:GetForwardVector().y * 100,160)
	vecColor = Vector(255,255,255)
	unit:SetOrigin(vecUnit)

	ParticleManager:SetParticleControl(caster.effectcircle, 0, caster:GetOrigin())
	
	local effect2ForwardRad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint) 
	local effect2VecForward = Vector(math.cos(effect2ForwardRad)*850,math.sin(effect2ForwardRad)*850,0) + caster:GetOrigin() + Vector(caster:GetForwardVector().x * 100,caster:GetForwardVector().y * 100,108)
	
	ParticleManager:SetParticleControl(caster.effectIndex, 0, caster:GetOrigin() + Vector(caster:GetForwardVector().x * 92,caster:GetForwardVector().y * 92,150))
	ParticleManager:SetParticleControl(caster.effectIndex, 1, effect2VecForward)
	ParticleManager:SetParticleControl(caster.effectIndex, 2, vecColor)
	local forwardRadwind = forwardRad + math.pi
	ParticleManager:SetParticleControl(caster.effectIndex, 8, Vector(math.cos(forwardRadwind),math.sin(forwardRadwind),0))
	ParticleManager:SetParticleControl(caster.effectIndex, 9, caster:GetOrigin() + Vector(caster:GetForwardVector().x * 100,caster:GetForwardVector().y * 100,108))

	ParticleManager:SetParticleControl(caster.effectIndex_b, 0, caster:GetOrigin() + Vector(caster:GetForwardVector().x * 92,caster:GetForwardVector().y * 92,150))
	ParticleManager:SetParticleControl(caster.effectIndex_b, 8, Vector(math.cos(forwardRadwind),math.sin(forwardRadwind),0))
end


function OnMarisa04SpellThink(keys)
	if(keys.ability:GetContext("ability_marisa_04_spark_lock")==FALSE)then
		AbilityMarisa:OnMarisa04Think(keys)
	end
end

function OnMarisa04SpellRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local unitIndex = keys.ability:GetContext("ability_marisa_04_spark_unit")

	local unit = EntIndexToHScript(unitIndex)
	if(unit~=nil)then
		unit:RemoveSelf()
		caster.effectcircle = -1
		caster.effectIndex = -1
	end
	keys.ability:SetContextNum("ability_marisa_04_spark_lock",TRUE,0)
end

function AbilityMarisa:OnMarisa01Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	local marisa01rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	local marisa01dis = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	keys.ability:SetContextNum("ability_marisa01_Rad",marisa01rad,0)
	keys.ability:SetContextNum("ability_marisa01_Dis",marisa01dis,0)
	--local marisa01time = marisa01dis/1250
	--UnitPauseTarget(caster,caster,marisa01time)
end

function AbilityMarisa:OnMarisa01Move(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	
	-- Ñ­»µ¸÷¸öÄ¿±êµ¥Î»
	for _,v in pairs(targets) do
		if(v:GetContext("ability_marisa01_damage")==nil)then
			v:SetContextNum("ability_marisa01_damage",TRUE,0)
		end
		if(v:GetContext("ability_marisa01_damage")==TRUE)then
			local damage_table = {
			    victim = v,
			    attacker = caster,
			    damage = keys.ability:GetAbilityDamage(),
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		    }
		    UnitDamageTarget(damage_table)
			v:SetContextNum("ability_marisa01_damage",FALSE,0)
			Timer.Wait 'ability_marisa01_damage_timer' (0.7,
			function()
				v:SetContextNum("ability_marisa01_damage",TRUE,0)
			end
	    	)
		end
	end
	local marisa01rad = keys.ability:GetContext("ability_marisa01_Rad")
	local vec = Vector(vecCaster.x+math.cos(marisa01rad)*keys.MoveSpeed/50,vecCaster.y+math.sin(marisa01rad)*keys.MoveSpeed/50,vecCaster.z)
	caster:SetOrigin(vec)
	local marisa01dis = keys.ability:GetContext("ability_marisa01_Dis")
	if(marisa01dis<0)then
		SetTargetToTraversable(caster)
		keys.ability:SetContextNum("ability_marisa01_Dis",0,0)
		caster:RemoveModifierByName("modifier_thdots_marisa01_think_interval")
	else
	    marisa01dis = marisa01dis - keys.MoveSpeed/50
	    keys.ability:SetContextNum("ability_marisa01_Dis",marisa01dis,0)
	end
end

function AbilityMarisa:OnMarisa02Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	keys.ability:SetContextNum("ability_marisa02_point_x",targetPoint.x,0)
	keys.ability:SetContextNum("ability_marisa02_point_y",targetPoint.y,0)
	keys.ability:SetContextNum("ability_marisa02_point_z",targetPoint.z,0)
	local unit = CreateUnitByName(
		"npc_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	keys.ability:SetContextNum("ability_marisa02_effectUnit",unit:GetEntityIndex(),0)

	unit:SetContextThink("ability_marisa02_effect_remove", 
		function()
			unit:RemoveSelf()
			return nil
		end, 
	1) 
end

function AbilityMarisa:OnMarisa02Damage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targetPoint = Vector(keys.ability:GetContext("ability_marisa02_point_x"),keys.ability:GetContext("ability_marisa02_point_y"),keys.ability:GetContext("ability_marisa02_point_z"))
	local targets = keys.target_entities

	local pointRad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
	local pointRad1 = pointRad + math.pi/3
	local pointRad2 = pointRad - math.pi/3
	vecCaster = Vector(vecCaster.x - math.cos(pointRad)*60,vecCaster.y - math.sin(pointRad)*60,vecCaster.z)
	
	local unitIndex = keys.ability:GetContext("ability_marisa02_effectUnit")
	local unit = EntIndexToHScript(unitIndex)
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_02_stars.vpcf", PATTACH_CUSTOMORIGIN, unit)
	local vecForward = Vector(500 * caster:GetForwardVector().x,500 * caster:GetForwardVector().y,caster:GetForwardVector().z)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin()+caster:GetForwardVector()*100)
	ParticleManager:SetParticleControl(effectIndex, 3, vecForward)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	
	-- Ñ­»µ¸÷¸öÄ¿±êµ¥Î»
	for _,v in pairs(targets) do
		local vVec = v:GetOrigin()
		local vRad = GetRadBetweenTwoVec2D(vecCaster,vVec)
		local vDistance = GetDistanceBetweenTwoVec2D(vVec,vecCaster)
		if(IsRadBetweenTwoRad2D(vRad,pointRad1,pointRad2))then
			local deal_damage = keys.ability:GetAbilityDamage()/5
			if(vDistance<260)then
				deal_damage = deal_damage *2
			end
			local damage_table = {
				victim = v,
				attacker = caster,
				damage = deal_damage,
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = 0
			}
			UnitDamageTarget(damage_table)
		end
	end
end

function AbilityMarisa:OnMarisa03Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	self.Marisa03Stars = {}
	-- ´´½¨ÐÇÐÇ
	for i = 0,3 do
		local vec = Vector(caster:GetOrigin().x + math.cos(i*math.pi/2) * 150,caster:GetOrigin().y + math.sin(i*math.pi/2) * 150,caster:GetOrigin().z + 300)
		local unit = CreateUnitByName(
		"npc_thdots_unit_marisa03_star"
		,vec
		,false
		,caster
		,caster
		,caster:GetTeam()
		)
		unit:SetContextNum("ability_marisa03_unit_rad",GetRadBetweenTwoVec2D(caster:GetOrigin(),vec),0)
		unit.hero = caster
		unitAbility = unit:FindAbilityByName("ability_thdots_marisa03_dealdamage")
		unitAbility:SetLevel(keys.ability:GetLevel())
		--unit:SetBaseDamageMax(keys.ability:GetAbilityDamage())
		--unit:SetBaseDamageMin(keys.ability:GetAbilityDamage())
		local effectIndex
		if(i==0)then
			effectIndex = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_03_stars.vpcf", PATTACH_CUSTOMORIGIN, unit)
		elseif(i==1)then
			effectIndex = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_03_stars_b.vpcf", PATTACH_CUSTOMORIGIN, unit)
		elseif(i==2)then
			effectIndex = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_03_stars_c.vpcf", PATTACH_CUSTOMORIGIN, unit)
		elseif(i==3)then
			effectIndex = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_03_stars_d.vpcf", PATTACH_CUSTOMORIGIN, unit)
		end
		ParticleManager:SetParticleControlEnt(effectIndex , 0, unit, 5, "follow_origin", Vector(0,0,0), true)

		Timer.Wait 'ability_marisa03_star_release' (keys.AbilityDuration,
			function()
				unit:ForceKill(true)
			end
	    )
		table.insert(self.Marisa03Stars,unit)
	end
end

function AbilityMarisa:OnMarisa03Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vCaster = caster:GetOrigin()
	local stars = self.Marisa03Stars
	for _,v in pairs(stars) do
		local vVec = v:GetOrigin()
		local turnRad = v:GetContext("ability_marisa03_unit_rad") + math.pi/120
		v:SetContextNum("ability_marisa03_unit_rad",turnRad,0)
		local turnVec = Vector(vCaster.x + math.cos(turnRad) * 150,vCaster.y + math.sin(turnRad) * 150,vCaster.z + 300)
		v:SetOrigin(turnVec)
	end
end

function AbilityMarisa:OnMarisa04Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targetPoint =  vecCaster + caster:GetForwardVector() --keys.target_points[1]
	local sparkRad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
	local findVec = Vector(vecCaster.x + math.cos(sparkRad) * keys.DamageLenth/2,vecCaster.y + math.sin(sparkRad) * keys.DamageLenth/2,vecCaster.z)
	local findRadius = math.sqrt(((keys.DamageLenth/2)*(keys.DamageLenth/2) + (keys.DamageWidth/2)*(keys.DamageWidth/2)))
	local DamageTargets = FindUnitsInRadius(
		   caster:GetTeam(),		--caster team
		   findVec,		            --find position
		   nil,					    --find entity
		   findRadius,		            --find radius
		   DOTA_UNIT_TARGET_TEAM_ENEMY,
		   keys.ability:GetAbilityTargetType(),
		   0, FIND_CLOSEST,
		   false
	    )
	for _,v in pairs(DamageTargets) do
		local vecV = v:GetOrigin()
		if(IsRadInRect(vecV,vecCaster,keys.DamageWidth,keys.DamageLenth,sparkRad))then
			local deal_damage = keys.ability:GetAbilityDamage()/100
			if(IsRadInRect(vecV,vecCaster,150,keys.DamageLenth,sparkRad))then
				deal_damage = deal_damage * 1.2
			end
			local damage_table = {
				victim = v,
				attacker = caster,
				damage = deal_damage,
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = 0
			}
			UnitDamageTarget(damage_table)
			UtilStun:UnitStunTarget(caster,v,0.02)
		end
	end
	MarisaSparkParticleControl(caster,targetPoint,keys.ability)
end

