if AbilityYoumu == nil then
	AbilityYoumu = class({})
end

function OnYoumu01SpellStart(keys)
	AbilityYoumu:OnYoumu01Start(keys)
end

function OnYoumu01SpellMove(keys)
	AbilityYoumu:OnYoumu01Move(keys)
end

function OnYoumu02SpellStart(keys)
	AbilityYoumu:OnYoumu02Start(keys)
end

function OnYoumu02SpellStartDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local damage_table = {
			    victim = target,
			    attacker = caster,
			    damage = keys.BounsDamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
	}
	UnitDamageTarget(damage_table)
end

function OnYoumu02SpellStartUnit(keys)
	AbilityYoumu:OnYoumu02StartUnit(keys)
end

function OnYoumu03SpellStart(keys)
	AbilityYoumu:OnYoumu03Start(keys)
end

function OnYoumu03SpellOrderMoved(keys)
	AbilityYoumu:OnYoumu03OrderMoved(keys)
end

function OnYoumu03SpellOrderAttack(keys)
	AbilityYoumu:OnYoumu03OrderAttack(keys)
end

function OnYoumu04SpellThink(keys)
	AbilityYoumu:OnYoumu04Think(keys)
end

function AbilityYoumu:OnYoumu01Start(keys)
	print("[AbilityYoumu01]Start")
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	local Youmu01rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	local Youmu01MoveSpeed = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),targetPoint)/2
	caster:SetContextNum("ability_Youmu01_Rad",Youmu01rad,0)
	caster:SetContextNum("ability_Youmu01_Move_Speed",Youmu01MoveSpeed,0)
	caster:SetContextNum("ability_Youmu01_Count",0,0)
end

function AbilityYoumu:OnYoumu01Move(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	local count = caster:GetContext("ability_Youmu01_Count")
	count = count + 0.2
	if(count == 0.2)then
	    -- Ñ­»µ¸÷¸öÄ¿±êµ¥Î»
		for _,v in pairs(targets) do
				local damage_table = {
					victim = v,
					attacker = caster,
					damage = keys.ability:GetAbilityDamage(),
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = keys.ability:GetAbilityTargetFlags()
				}
				UnitDamageTarget(damage_table)
		end
		caster:SetContextNum("ability_Youmu01_Count",0,0)
		local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/youmu/youmu_01_blink_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 3, caster:GetOrigin())
		ParticleManager:ReleaseParticleIndex(effectIndex)
	end
	local Youmu01rad = caster:GetContext("ability_Youmu01_Rad")
	local Youmu01MoveSpeed = caster:GetContext("ability_Youmu01_Move_Speed")
	local vec = Vector(vecCaster.x+math.cos(Youmu01rad)*Youmu01MoveSpeed,vecCaster.y+math.sin(Youmu01rad)*Youmu01MoveSpeed,vecCaster.z)
	local unitIndex = caster:GetContext("Youmu03_Effect_Unit")
	if(unitIndex~=nil)then
		local unit = EntIndexToHScript(unitIndex)
		if(unit~=nil)then
			unit:SetOrigin(vec)
		end
	end
	caster:SetOrigin(vec)
	if(count==0.2)then
		SetTargetToTraversable(caster)
	end
end

function AbilityYoumu:OnYoumu02Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if(target:IsTower()==true)then
		return
	end
	if(target:GetContext("ability_Youmu02_Armor_Decrease")==nil)then
		target:SetContextNum("ability_Youmu02_Armor_Decrease",0,0)
	end
	local decreaseArmor = target:GetContext("ability_Youmu02_Armor_Decrease")
	decreaseArmor = decreaseArmor + keys.DecreaseArmor
	if(decreaseArmor<keys.DecreaseMaxArmor)then
		target:SetContextNum("ability_Youmu02_Armor_Decrease",decreaseArmor,0)
		target:SetPhysicalArmorBaseValue(keys.target:GetPhysicalArmorBaseValue() - keys.DecreaseArmor)
		target:SetThink(
			function()
				target:SetPhysicalArmorBaseValue(keys.target:GetPhysicalArmorBaseValue() + keys.DecreaseArmor)	
				local decreaseArmorNow = target:GetContext("ability_Youmu02_Armor_Decrease") + keys.DecreaseArmor
				target:SetContextNum("ability_Youmu02_Armor_Decrease",decreaseArmorNow,0)	
			end, 
			DoUniqueString("ability_Youmu02_Armor_Decrease_Duration"), 
			keys.Duration
			)	
	end
end

function AbilityYoumu:OnYoumu02StartUnit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if(target:IsTower()==true)then
		return
	end

	if(target:GetContext("ability_Youmu02_Armor_Decrease")==nil)then
		target:SetContextNum("ability_Youmu02_Armor_Decrease",0,0)
	end
	local decreaseArmor = target:GetContext("ability_Youmu02_Armor_Decrease")
	decreaseArmor = decreaseArmor + keys.DecreaseArmor
	if(decreaseArmor<keys.DecreaseMaxArmor)then
		target:SetContextNum("ability_Youmu02_Armor_Decrease",decreaseArmor,0)
		target:SetPhysicalArmorBaseValue(keys.target:GetPhysicalArmorBaseValue() - keys.DecreaseArmor)
		target:SetThink(
			function()
				target:SetPhysicalArmorBaseValue(keys.target:GetPhysicalArmorBaseValue() + keys.DecreaseArmor)	
				local decreaseArmorNow = target:GetContext("ability_Youmu02_Armor_Decrease") + keys.DecreaseArmor
				target:SetContextNum("ability_Youmu02_Armor_Decrease",decreaseArmorNow,0)	
			end, 
			DoUniqueString("ability_Youmu02_Armor_Decrease_Duration"), 
			keys.Duration
			)	
	end
end

function AbilityYoumu:OnYoumu03Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local unit = CreateUnitByName(
		"npc_thdots_unit_youmu03_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	caster:SetContextNum("Youmu03_Effect_Unit" , unit:GetEntityIndex(), 0)
	local bounsDamage = caster:GetAttackDamage()*keys.BounsDamage
	unit:SetBaseDamageMax(bounsDamage+1)
	unit:SetBaseDamageMin(bounsDamage-1)
	unit:SetBaseMoveSpeed(caster:GetBaseMoveSpeed())
	unit:SetBaseAttackTime(caster:GetBaseAttackTime())
	unit:AddAbility("ability_thdots_youmu02_unit")
	local ability_unit_youmu02 = unit:FindAbilityByName("ability_thdots_youmu02_unit")
	local ability_caster_youmu02_level = caster:FindAbilityByName("ability_thdots_youmu02"):GetLevel()
	ability_unit_youmu02:SetLevel(ability_caster_youmu02_level)
	GameRules:GetGameModeEntity():SetThink(
			function()
			    caster:RemoveModifierByName("modifier_thdots_youmu03_spawn")
				unit:RemoveSelf()
			end, 
			DoUniqueString("ability_Youmu03_Unit_Duration"), 
			keys.Duration
			)	
end

function AbilityYoumu:OnYoumu03OrderMoved(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local unitIndex = caster:GetContext("Youmu03_Effect_Unit")
	local unit = EntIndexToHScript(unitIndex)
	unit:MoveToPosition(caster:GetOrigin())
end

function AbilityYoumu:OnYoumu03OrderAttack(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local unitIndex = caster:GetContext("Youmu03_Effect_Unit")
	local unit = EntIndexToHScript(unitIndex)
	unit:MoveToTargetToAttack(target)
end

function AbilityYoumu:OnYoumu04Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local vecCaster = caster:GetOrigin()
	local vecTarget = target:GetOrigin()
	local Youmu04Rad
	local count
	
	if(caster:GetContext("ability_Youmu04_Count") == nil)then
	    caster:SetContextNum("ability_Youmu04_Count",0,0)
	end
	if(caster:GetContext("ability_Youmu04_Rad") == nil or caster:GetContext("ability_Youmu04_Rad") == 0) then
		Youmu04Rad = GetRadBetweenTwoVec2D(vecTarget,vecCaster)
		caster:SetContextNum("ability_Youmu04_Rad",Youmu04Rad,0)
	end
	Youmu04Rad = caster:GetContext("ability_Youmu04_Rad")
	count = caster:GetContext("ability_Youmu04_Count")
	if(count == 0)then
	    UnitPauseTarget(caster,keys.target,1.0)
		UnitPauseTarget(caster,keys.target,1.0)
	end
	
	if(count%2 == 0)then
		Youmu04Rad = Youmu04Rad + 210*math.pi/180
		caster:SetContextNum("ability_Youmu04_Rad",Youmu04Rad,0)
		local deal_damage = keys.ability:GetAbilityDamage() + keys.AbilityMulti * caster:GetPrimaryStatValue()
		print(tostring(deal_damage))
		local damage_table = {
				victim = keys.target,
				attacker = caster,
				damage = deal_damage/5,
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = keys.ability:GetAbilityTargetFlags()
		}
		local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/youmu/youmu_04_sword_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
		local effect2VecForward = Vector(vecTarget.x+math.cos(Youmu04Rad)*500,vecTarget.y+math.sin(Youmu04Rad)*500,vecCaster.z)
		ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, effect2VecForward)
		ParticleManager:ReleaseParticleIndex(effectIndex)
	    target:EmitSound("Hero_Juggernaut.Attack")
		UnitDamageTarget(damage_table)
	end
	local vec = Vector(vecTarget.x+math.cos(Youmu04Rad)*250,vecTarget.y+math.sin(Youmu04Rad)*250,vecCaster.z)
	caster:SetOrigin(vec)
	count = count +1
	caster:SetContextNum("ability_Youmu04_Count",count,0)
	print(tostring(count))
	if(count>=10)then
		caster:SetOrigin(vecTarget)
		caster:SetContextNum("ability_Youmu04_Count",0,0)
		caster:SetContextNum("ability_Youmu04_Rad",0,0)
		return
	end
end