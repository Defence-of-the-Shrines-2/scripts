if AbilitySakuya == nil then
	AbilitySakuya = class({})
end

function OnSakuyaExSpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:SetContextNum("ability_sakuya_01_stun", TRUE, 0) 
end

function OnSakuya01SpellReset(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(caster:GetContext("sakuya04_cooldown_reset")==TRUE)then
		keys.ability:EndCooldown()
		local usedCount = caster:GetContext("sakuya04_ability_01_used_count") + 1
		caster:SetMana(caster:GetMana() - usedCount * 0.25 * keys.ability:GetManaCost(keys.ability:GetLevel()))
		caster:SetContextNum("sakuya04_ability_01_used_count", usedCount , 0)
	end
end

function OnSakuya01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local intBouns = (caster:GetIntellect()	- (caster:GetIntellect()%6)) / 6 * keys.IntMulti + 1
	local agiBouns = (caster:GetAgility() - (caster:GetAgility()%6)) / 6 * keys.AgiMulti
	local bounsDamage = 0
	if(caster:GetContext("ability_sakuya_01_stun")==TRUE)then
		UtilStun:UnitStunTarget( caster,target,keys.StunDuration)
		bounsDamage = keys.DamageBouns
	end
	local dealdamage = (agiBouns + keys.Damage + bounsDamage) * intBouns
	local damage_table = {
			    victim = target,
			    attacker = caster,
			    damage = dealdamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
	}
	UnitDamageTarget(damage_table)

	Timer.Wait 'ability_sakuya_01_stun_timer' (0.5,
		function()
			caster:SetContextNum("ability_sakuya_01_stun", FALSE, 0) 
		end
	)	
end

function OnSakuya02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	caster:SetContextNum("ability_sakuya02_point_x",targetPoint.x,0)
	caster:SetContextNum("ability_sakuya02_point_y",targetPoint.y,0)
	caster:SetContextNum("ability_sakuya02_point_z",targetPoint.z,0)
end

function OnSakuya02SpellDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targetPoint = Vector(caster:GetContext("ability_sakuya02_point_x"),caster:GetContext("ability_sakuya02_point_y"),caster:GetContext("ability_sakuya02_point_z"))
	local targets = keys.target_entities

	local pointRad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
	local pointRad1 = pointRad + math.pi * (keys.DamageRad/180)
	local pointRad2 = pointRad - math.pi * (keys.DamageRad/180)

	local forwardVec = Vector( math.cos(pointRad) * 2000 , math.sin(pointRad) * 2000 , 128 )
	local knifeTable = {
	    Ability        	 	=   keys.ability,
		EffectName			=	"particles/thd2/heroes/sakuya/ability_sakuya_01.vpcf",
		vSpawnOrigin		=	vecCaster,
		fDistance			=	keys.DamageRadius,
		fStartRadius		=	120,
		fEndRadius			=	120,
		Source         	 	=   caster,
		bHasFrontalCone		=	false,
		bRepalceExisting 	=  false,
		iUnitTargetTeams		=	"DOTA_UNIT_TARGET_TEAM_ENEMY",
		iUnitTargetTypes		=	"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_CREEP",
		iUnitTargetFlags		=	"DOTA_UNIT_TARGET_FLAG_NONE",
		fExpireTime     =   GameRules:GetGameTime() + 10.0,
		bDeleteOnHit    =   false,
		vVelocity       =   forwardVec,
		bProvidesVision	=	true,
		iVisionRadius	=	400,
		iVisionTeamNumber = caster:GetTeamNumber()
	}

	ProjectileManager:CreateLinearProjectile(knifeTable)

	for i=1,keys.ability:GetLevel() do
		local iVec = Vector( math.cos(pointRad + math.pi/18*(i+0.5)) * 2000 , math.sin(pointRad + math.pi/18*(i+0.5)) * 2000 , 128 )
		knifeTable.vVelocity = iVec
		ProjectileManager:CreateLinearProjectile(knifeTable)
		iVec = Vector( math.cos(pointRad - math.pi/18*(i+0.5)) * 2000 , math.sin(pointRad - math.pi/18*(i+0.5)) * 2000 , 128 )
		knifeTable.vVelocity = iVec
		ProjectileManager:CreateLinearProjectile(knifeTable)
	end

	for _,v in pairs(targets) do
		local vVec = v:GetOrigin()
		local vRad = GetRadBetweenTwoVec2D(vecCaster,vVec)
		local vDistance = GetDistanceBetweenTwoVec2D(vVec,vecCaster)
		if(IsRadBetweenTwoRad2D(vRad,pointRad1,pointRad2))then
			local intBouns = (caster:GetIntellect()	- (caster:GetIntellect()%6)) / 6 * keys.IntMulti + 1
			local agiBouns = (caster:GetAgility() - (caster:GetAgility()%6)) / 6 * keys.AgiMulti
			local dealdamage = (agiBouns + keys.Damage) * intBouns
			local damage_table = {
				victim = v,
				attacker = caster,
				damage = dealdamage,
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = 0
			}
			UnitDamageTarget(damage_table)
		end
	end
	if(caster:GetContext("sakuya04_cooldown_reset")==TRUE)then
		keys.ability:EndCooldown()
		local usedCount = caster:GetContext("sakuya04_ability_02_used_count") + 1
		caster:SetMana(caster:GetMana() - usedCount * 0.25 * keys.ability:GetManaCost(keys.ability:GetLevel()))
		caster:SetContextNum("sakuya04_ability_02_used_count", usedCount , 0)
	end
end


function OnSakuya03SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	caster:SetContextNum("ability_sakuya03_point_x",targetPoint.x,0)
	caster:SetContextNum("ability_sakuya03_point_y",targetPoint.y,0)
	caster:SetContextNum("ability_sakuya03_point_z",targetPoint.z,0)
end

function OnSakuya03SpellDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targetPoint = Vector(caster:GetContext("ability_sakuya03_point_x"),caster:GetContext("ability_sakuya03_point_y"),caster:GetContext("ability_sakuya03_point_z"))
	local targets = keys.target_entities

	local pointRad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)

	local forwardVec = Vector( math.cos(pointRad) * 2000 , math.sin(pointRad) * 2000 , 128 )
	local knifeTable = {
	    Ability        	 	=   keys.ability,
		EffectName			=	"particles/thd2/heroes/sakuya/ability_sakuya_01.vpcf",
		vSpawnOrigin		=	vecCaster,
		fDistance			=	keys.DamageRadius,
		fStartRadius		=	120,
		fEndRadius			=	120,
		Source         	 	=   caster,
		bHasFrontalCone		=	false,
		bRepalceExisting 	=  false,
		iUnitTargetTeams		=	"DOTA_UNIT_TARGET_TEAM_ENEMY",
		iUnitTargetTypes		=	"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_CREEP",
		iUnitTargetFlags		=	"DOTA_UNIT_TARGET_FLAG_NONE",
		fExpireTime     =   GameRules:GetGameTime() + 10.0,
		bDeleteOnHit    =   false,
		vVelocity       =   forwardVec,
		bProvidesVision	=	true,
		iVisionRadius	=	400,
		iVisionTeamNumber = caster:GetTeamNumber()
	}

	for i=0,5 do
		local iVec = Vector( math.cos(pointRad + math.pi/6*i) * 2000 , math.sin(pointRad + math.pi/6*i) * 2000 , 128 )
		knifeTable.vVelocity = iVec
		ProjectileManager:CreateLinearProjectile(knifeTable)
		iVec = Vector( math.cos(pointRad - math.pi/6*i) * 2000 , math.sin(pointRad - math.pi/6*i) * 2000 , 128 )
		knifeTable.vVelocity = iVec
		ProjectileManager:CreateLinearProjectile(knifeTable)
	end

	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/sakuya/ability_sakuya_03.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effectIndex)

	caster:SetOrigin(targetPoint)
	SetTargetToTraversable(caster)

	for _,v in pairs(targets) do
		local damage_table = {
			victim = v,
			attacker = caster,
			damage = keys.Damage,
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
	if(caster:GetContext("sakuya04_cooldown_reset")==TRUE)then
		keys.ability:EndCooldown()
		local usedCount = caster:GetContext("sakuya04_ability_03_used_count") + 1
		caster:SetMana(caster:GetMana() - usedCount * 0.25 * keys.ability:GetManaCost(keys.ability:GetLevel()))
		caster:SetContextNum("sakuya04_ability_03_used_count", usedCount , 0)
	end
end

function OnSakuya04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local unit = CreateUnitByName(
		"npc_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	local nEffectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/sakuya/ability_sakuya_04.vpcf",PATTACH_CUSTOMORIGIN,unit)
	local vecCorlor = Vector(255,0,0)
	ParticleManager:SetParticleControl( nEffectIndex, 0, caster:GetOrigin())
		
	caster:SetContextNum("sakuya04_Effect_Unit" , unit:GetEntityIndex(), 0)
	caster:SetContextNum("sakuya04_ability_01_used_count" , 0, 0)
	caster:SetContextNum("sakuya04_ability_02_used_count" , 0, 0)
	caster:SetContextNum("sakuya04_ability_03_used_count" , 0, 0)

	local ability = caster:FindAbilityByName("ability_thdots_sakuya01") 
	if(ability~=nil)then
		ability:EndCooldown()
	end
	ability = caster:FindAbilityByName("ability_thdots_sakuya02") 
	if(ability~=nil)then
		ability:EndCooldown()
	end
	ability = caster:FindAbilityByName("ability_thdots_sakuya03") 
	if(ability~=nil)then
		ability:EndCooldown()
	end

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('ability_sakuya04_remove'),
    	function ()
		    if (unit~=nil) then
		        unit:RemoveSelf()
		        caster:SetContextNum("sakuya04_cooldown_reset", FALSE, 0)
		    	return nil
			end
	    end,keys.Ability_Duration+0.1
	)
end

function OnSakuya04SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local effectUnitIndex = caster:GetContext("sakuya04_Effect_Unit")
	local effectUnit = EntIndexToHScript(effectUnitIndex)
	local vecEffectUnit = effectUnit:GetOrigin()

	if(GetDistanceBetweenTwoVec2D(vecCaster,vecEffectUnit) <= keys.Radius)then
		caster:SetContextNum("sakuya04_cooldown_reset", TRUE, 0)
	else
		caster:SetContextNum("sakuya04_cooldown_reset", FALSE, 0)
	end
end