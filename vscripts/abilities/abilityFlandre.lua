if AbilityFlandre == nil then
	AbilityFlandre = class({})
end

function OnFlandre02SpellStartUnit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target

	if(target:GetContext("ability_flandre02_Speed_Decrease")==nil)then
		target:SetContextNum("ability_flandre02_Speed_Decrease",0,0)
	end
	local decreaseSpeedCount = target:GetContext("ability_flandre02_Speed_Decrease")
	decreaseSpeedCount = decreaseSpeedCount + 1
	if(decreaseSpeedCount>keys.DecreaseMaxSpeed)then
		target:RemoveModifierByName("modifier_flandre02_slow")
	else
		target:SetContextNum("ability_flandre02_Speed_Decrease",decreaseSpeedCount,0)
		target:SetThink(
			function()
				target:RemoveModifierByName("modifier_flandre02_slow")
				local decreaseSpeedNow = target:GetContext("ability_flandre02_Speed_Decrease") - 1
				target:SetContextNum("ability_flandre02_Speed_Decrease",decreaseSpeedNow,0)	
			end, 
			DoUniqueString("ability_flandre02_Speed_Decrease_Duration"), 
			keys.Duration
		)	
	end
end

function OnFlandre04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	keys.ability:SetContextNum("ability_flandre04_multi_count",0,0)
	local count = 1
	local illusions = FindUnitsInRadius(
		   caster:GetTeam(),		
		   caster:GetOrigin(),		
		   nil,					
		   3000,		
		   DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		   DOTA_UNIT_TARGET_ALL,
		   DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, 
		   FIND_CLOSEST,
		   false
	)

	for _,v in pairs(illusions) do
		if(v:IsIllusion())then
			count = count + 1
			v:MoveToPosition(caster:GetOrigin())
			v:SetThink(
				function()
					OnFlandre04illusionsRemove(v,caster)
					return 0.02
				end, 
				DoUniqueString("ability_collection_power"),
			0.02)
		end
	end

	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_ambient.vpcf", PATTACH_CUSTOMORIGIN, caster) 
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_attack1", Vector(0,0,0), true)
<<<<<<< HEAD
	ParticleManager:DestroyParticleTime(effectIndex,keys.Duration)

	keys.ability:SetContextNum("ability_flandre04_multi_count",count,0)
	keys.ability:SetContextNum("ability_flandre04_effectIndex",effectIndex,0)
=======

	caster:SetContextNum("ability_flandre04_multi_count",count,0)
	caster:SetContextNum("ability_flandre04_effectIndex",effectIndex,0)
>>>>>>> origin/master
end

function OnFlandre04SpellRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local count = keys.ability:GetContext("ability_flandre04_multi_count")
	count = count - 1
	keys.ability:SetContextNum("ability_flandre04_multi_count",count,0)
	if(count<=0)then
		caster:RemoveModifierByName("modifier_thdots_flandre_04_multi")
	end
end

function OnFlandre04EffectRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
<<<<<<< HEAD
	local effectIndex = keys.ability:GetContext("ability_flandre04_effectIndex")
=======
	local effectIndex = caster:GetContext("ability_flandre04_effectIndex")
>>>>>>> origin/master
	ParticleManager:DestroyParticle(effectIndex,true)
end

function OnFlandre04illusionsRemove(target,caster)
	local vecTarget = target:GetOrigin()
	local vecCaster = caster:GetOrigin()
	local speed = 30
	local radForward = GetRadBetweenTwoVec2D(vecTarget,vecCaster)
	local vecForward = Vector(math.cos(radForward) * speed,math.sin(radForward) * speed,1)
	vecTarget = vecTarget + vecForward
	
	target:SetForwardVector(vecForward)
	target:SetOrigin(vecTarget)
	if(GetDistanceBetweenTwoVec2D(vecTarget,vecCaster)<50)then
		local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/flandre/ability_flandre_04_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vecCaster)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		target:RemoveSelf()
	end
end
