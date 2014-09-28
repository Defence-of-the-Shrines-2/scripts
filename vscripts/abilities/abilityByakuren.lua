function OnByakuren01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	local dealdamage = keys.ability:GetAbilityDamage() - keys.AOEDamage
	local damage_target = {
		victim = keys.target,
		attacker = caster,
		damage = dealdamage,
		damage_type = keys.ability:GetAbilityDamageType(), 
	    damage_flags = 0
	}
	UnitDamageTarget(damage_target)
	for _,v in pairs(targets) do
		local damage_table = {
			    victim = v,
			    attacker = caster,
			    damage = keys.AOEDamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
		UtilStun:UnitStunTarget(caster,v,keys.StunDuration)
	end
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, keys.target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 5, keys.target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effectIndex)
end

function OnByakuren02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local manaCost = keys.ManaCost * caster:GetMaxMana()
	if(manaCost>caster:GetMana())then
		keys.ability:EndCooldown()
		return
	end
	
	caster:SetMana(caster:GetMana()-manaCost)
	local vecCaster = caster:GetOrigin()
	local target = keys.target
	local dealdamage = keys.AbilityMulti*manaCost
	local damage_target = {
		victim = keys.target,
		attacker = caster,
		damage = dealdamage,
		damage_type = keys.ability:GetAbilityDamageType(), 
	    damage_flags = 0
	}
	UnitDamageTarget(damage_target)
	
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_pulse_nova_h.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 2, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effectIndex)
end

function OnByakuren03SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local target = keys.target
	local vecTarget = target:GetOrigin()
	
	if(target:GetTeam()==caster:GetTeam())then
		local vecMove = vecCaster + caster:GetForwardVector() * 60
		target:SetOrigin(vecMove)
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_pulse_nova_h.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vecTarget)
		ParticleManager:SetParticleControl(effectIndex, 1, vecTarget)
		ParticleManager:SetParticleControl(effectIndex, 2, vecTarget)
		ParticleManager:ReleaseParticleIndex(effectIndex)
		target:EmitSound("Hero_Weaver.TimeLapse")
	else
		local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/byakuren/ability_byakuren_03.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vecTarget)
		target:SetThink(
				function()
					target:SetOrigin(vecTarget)
					target:EmitSound("Hero_Weaver.TimeLapse")
					return nil
				end, 
		"ability_byakuren_03_return",
		3.0)
	end
end

function OnByakuren04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	local dealdamage = keys.ability:GetAbilityDamage() + keys.AbilityMulti * ( caster:GetMaxHealth() - caster:GetHealth())
	local damage_target = {
		victim = keys.target,
		attacker = caster,
		damage = dealdamage/2,
		damage_type = keys.ability:GetAbilityDamageType(), 
	    damage_flags = 0
	}
	UnitDamageTarget(damage_target)
	
	for _,v in pairs(targets) do
		local damage_table = {
			    victim = v,
			    attacker = caster,
			    damage = dealdamage/2,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
	caster:SetHealth(caster:GetHealth()+dealdamage)
end

function OnByakuren04SpellThinkStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(caster:GetContext("ability_byakuren04_health_old")==nil)then
		caster:SetContextNum("ability_byakuren04_health_old",0,0)
	end
	if(caster:GetContext("ability_byakuren04_think")==nil)then
		caster:SetContextThink("ability_byakuren04_think", 
		function()
			OnByakuren04SpellThink(keys)
			return 0.05
		end, 
		0.05)
	end
end


function OnByakuren04SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ability = keys.ability
	local increaseHealth = caster:GetMaxMana() * keys.BounsHealth * ability:GetLevel()
	local newRealBaseHealth = caster:GetBaseMaxHealth() + increaseHealth
	local intNewRealBaseHealth = newRealBaseHealth - newRealBaseHealth%1
	local changeHealth = caster:GetMaxHealth() - intNewRealBaseHealth
	if(math.abs(changeHealth)<=2)then
		caster:SetContextNum("ability_byakuren04_health_old",caster:GetHealth(),0)
		return
	end
	
	local hp = caster:GetContext("ability_byakuren04_health_old")
	
	caster:SetMaxHealth(intNewRealBaseHealth)
	if(hp~=0)then
		caster:SetHealth(hp)
	end
end
