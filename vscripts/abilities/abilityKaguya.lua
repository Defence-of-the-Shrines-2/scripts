if AbilityKaguya == nil then
	AbilityKaguya = class({})
end

function OnKaguya01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	--设置计数器，控制旋转角度
	caster:SetContextNum("ability_kaguya01_spell_count", 0, 0)
end

function OnKaguya01SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local forwardVector = caster:GetForwardVector()
	local count = caster:GetContext("ability_kaguya01_spell_count")
	local rollRad = count*math.pi*2/7
	local forwardCos = forwardVector.x
	local forwardSin = forwardVector.y
	local damageVector =  Vector(math.cos(rollRad)*forwardCos - math.sin(rollRad)*forwardSin,
								 forwardSin*math.cos(rollRad) + forwardCos*math.sin(rollRad),
								 0) * 350 + vecCaster

	local effectIndex
	if(count%3==0)then
		effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/kaguya/ability_kaguya01_light.vpcf", PATTACH_CUSTOMORIGIN, caster)
	elseif(count%3==1)then
		effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/kaguya/ability_kaguya01_light_green.vpcf", PATTACH_CUSTOMORIGIN, caster)
	elseif(count%3==2)then
		effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/kaguya/ability_kaguya01_light_red.vpcf", PATTACH_CUSTOMORIGIN, caster)
	end		
	count = count + 1
	caster:SetContextNum("ability_kaguya01_spell_count", count, 0)
	
	ParticleManager:SetParticleControl(effectIndex, 0, damageVector)
	ParticleManager:SetParticleControl(effectIndex, 1, damageVector)
	ParticleManager:ReleaseParticleIndex(effectIndex) 
	
	local targets = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   damageVector,							--find position
				   nil,										--find entity
				   keys.DamageRadius,						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   DAMAGE_TYPE_MAGICAL,
				   0, FIND_CLOSEST,
				   false
			    )
	for _,v in pairs(targets) do
		local damage_table = {
			    victim = v,
			    attacker = caster,
			    damage = keys.ability:GetAbilityDamage(),
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
	local damage_table_caster = {
			victim = caster,
			attacker = caster,
			damage = keys.HealthCost * caster:GetMaxHealth(),
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = 0
	}
	UnitDamageTarget(damage_table_caster)
end
