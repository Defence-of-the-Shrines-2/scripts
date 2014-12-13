function OnUtsuho01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local target = keys.target
	local dealdamage = keys.ability:GetAbilityDamage()

	local damage_target = {
		victim = keys.target,
		attacker = caster,
		damage = dealdamage,
		damage_type = keys.ability:GetAbilityDamageType(), 
	    damage_flags = 0
	}
	UnitDamageTarget(damage_target)
end

function OnUtsuho01FireDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		local damage_table = {
			    victim = v,
			    attacker = caster,
			    damage = keys.AbilityDamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
end

function OnUtsuho02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		local damage_table = {
			    victim = v,
			    attacker = caster,
			    damage = keys.AbilityDamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
end

function OnUtsuho03SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		local damage_table = {
			    victim = v,
			    attacker = caster,
			    damage = keys.AbilityDamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
end

function OnUtsuho04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	caster:SetContextNum("ability_utsuho04_point_x",targetPoint.x,0)
	caster:SetContextNum("ability_utsuho04_point_y",targetPoint.y,0)
	caster:SetContextNum("ability_utsuho04_point_z",targetPoint.z,0)
	caster:SetContextNum("ability_utsuho04_timer_count",0,0)
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/utsuho/ability_utsuho04_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, targetPoint)
	ParticleManager:SetParticleControl(effectIndex, 1, targetPoint)
	ParticleManager:SetParticleControl(effectIndex, 3, targetPoint)
	caster:SetContextNum("ability_utsuho04_effect_index",effectIndex,0)
end

function OnUtsuho04SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local tx = caster:GetContext("ability_utsuho04_point_x")
	local ty = caster:GetContext("ability_utsuho04_point_y")
	local tz = caster:GetContext("ability_utsuho04_point_z")
	local targetPoint = Vector(tx,ty,tz)
	local targets = FindUnitsInRadius(
		   caster:GetTeam(),		--caster team
		   targetPoint,				--find position
		   nil,						--find entity
		   keys.Radius,				--find radius
		   DOTA_UNIT_TARGET_TEAM_ENEMY,
		   keys.ability:GetAbilityTargetType(),
		   0, FIND_CLOSEST,
		   false
	)
	local count = caster:GetContext("ability_utsuho04_timer_count")
	caster:SetContextNum("ability_utsuho04_timer_count",count+0.1,0)

	for _,v in pairs(targets) do
		local dis = GetDistanceBetweenTwoVec2D(targetPoint,v:GetOrigin())
		if(dis<keys.DamageRadius and (v:GetClassname()~="npc_dota_roshan"))then
			local damage_table = {
			    victim = v,
			    attacker = caster,
			    damage = keys.Damage/10,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
			}
			UnitDamageTarget(damage_table)
		end
		local rad = GetRadBetweenTwoVec2D(targetPoint,v:GetOrigin())
		if(dis>=(keys.Gravity/10))then
			v:SetOrigin(v:GetOrigin() - keys.Gravity/10 * Vector(math.cos(rad),math.sin(rad),0))
		end
	end
end


function OnUtsuho04SpellRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targets = keys.target_entities
	local count = caster:GetContext("ability_utsuho04_timer_count")
	local effectIndex = caster:GetContext("ability_utsuho04_effect_index") 
	local tx = caster:GetContext("ability_utsuho04_point_x")
	local ty = caster:GetContext("ability_utsuho04_point_y")
	local tz = caster:GetContext("ability_utsuho04_point_z")
	local targetPoint = Vector(tx,ty,tz)
	ParticleManager:DestroyParticleSystem(effectIndex,true)
	effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, targetPoint)
	ParticleManager:SetParticleControl(effectIndex, 1, targetPoint)
	ParticleManager:SetParticleControl(effectIndex, 3, targetPoint)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	for _,v in pairs(targets) do
		local damage_table = {
			    victim = v,
			    attacker = caster,
			    damage = keys.ability:GetAbilityDamage() * (count/6.5),
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
		SetTargetToTraversable(v)
	end
end