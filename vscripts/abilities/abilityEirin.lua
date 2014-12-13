if AbilityEirin == nil then
	AbilityEirin = class({})
end

function OnEirin02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	caster:SetContextNum("ability_eirin02_spell_x", vecCaster.x, 0)
	caster:SetContextNum("ability_eirin02_spell_y", vecCaster.y, 0)
	caster:SetContextNum("ability_eirin02_spell_z", vecCaster.z, 0)
end

function OnEirin02SpellHit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local vecTarget = target:GetOrigin()
	local dealdamage = keys.ability:GetAbilityDamage()
	if(target:GetTeam()~=caster:GetTeam())then
		local damage_table = {
			    victim = target,
			    attacker = caster,
			    damage = dealdamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)	
		local spellPoint = Vector(caster:GetContext("ability_eirin02_spell_x"),caster:GetContext("ability_eirin02_spell_y"),caster:GetContext("ability_eirin02_spell_z"))
		local dis = GetDistanceBetweenTwoVec2D(spellPoint,target:GetOrigin())
		local duration = (dis-dis%150)/150*keys.StunDuration
		if(duration>=2.0)then
			duration = 2.0
		end
	    UtilStun:UnitStunTarget(caster,target,duration)
	else
		target:SetHealth(target:GetHealth() + dealdamage)
	end
	
	local effectIndex = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_witchdoctor/witchdoctor_ward_skull.vpcf", 
		PATTACH_CUSTOMORIGIN, 
		caster)
	ParticleManager:SetParticleControl(effectIndex, 0, vecTarget)
	ParticleManager:SetParticleControl(effectIndex, 1, vecTarget)
	ParticleManager:SetParticleControl(effectIndex, 2, vecTarget)

	EmitSoundOn("Hero_Puck.Dream_Coil", target)


	Timer.Loop 'ability_eirin02_spell_heal' (0.2, 20,
			function(i)
				local targets = FindUnitsInRadius(
				   caster:GetTeam(),		--caster team
				   vecTarget,				--find position
				   nil,						--find entity
				   keys.Radius,				--find radius
				   DOTA_UNIT_TARGET_TEAM_BOTH,
				   DAMAGE_TYPE_MAGICAL,
				   0, FIND_CLOSEST,
				   false
			    )
				for k,v in pairs(targets) do
					if(v:GetTeam()~=caster:GetTeam())then
						local damage_table_heal = {
				   	 		victim = v,
				   	 		attacker = caster,
				   			damage = keys.Damage/5*0.75,
				   	 		damage_type = keys.ability:GetAbilityDamageType(), 
		    	  	 		damage_flags = 0
						}
				   		UnitDamageTarget(damage_table_heal)
				   	else
				   		v:Heal(keys.Damage/5,caster)
				   		local healEffectIndex = ParticleManager:CreateParticle(
							"particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration_heal.vpcf", 
							PATTACH_CUSTOMORIGIN, 
						v)

						ParticleManager:SetParticleControl(healEffectIndex, 0, v:GetOrigin())
				   		Timer.Wait 'ability_eirin02_remove_heal_effect' (1,
							function()
								ParticleManager:DestroyParticleSystem(healEffectIndex,true)
							end
						)
				   	end
			    end
			end
	)
	Timer.Wait 'ability_eirin02_remove_effect' (4,
			function()
				ParticleManager:DestroyParticleSystem(effectIndex,true)
			end
		)
end

function OnEirin03EffectInvisible(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	target:AddNewModifier(nil, nil, "modifier_invisible", {duration=keys.Duration})
end

function OnEirin04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	UnitGraveTarget(caster,target)
end

function OnEirin04SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if(target:GetHealth()<=5)then
		target:RemoveModifierByName("modifier_ability_thdots_eirin04_effect")
		
		local effectIndex = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", 
			PATTACH_CUSTOMORIGIN, 
			target)
		ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin()/5)
		ParticleManager:SetParticleControl(effectIndex, 2, target:GetOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		target:SetHealth(target:GetMaxHealth())
	end
end

function OnEirin04SpellRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	target:RemoveModifierByName("modifier_dazzle_shallow_grave")
	target:StopSound("Hero_Dazzle.Weave")
end