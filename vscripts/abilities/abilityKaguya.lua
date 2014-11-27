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

function OnKaguyaSwapAbility(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(caster:GetContext("ability_kaguya02_swap_ability")==nil)then
		caster:SetContextNum("ability_kaguya02_swap_ability",0,0)
	end
	local abilityNumber = caster:GetContext("ability_kaguya02_swap_ability")
	if(abilityNumber==0)then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kaguya02_Brilliant_Dragon_Bullet", nil)
		caster:RemoveModifierByName("modifier_thdots_kaguya02_Life_Spring_Infinity") 
		caster:SetContextNum("ability_kaguya02_swap_ability",1,0)
	elseif(abilityNumber==1)then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kaguya02_Buddhist_Diamond", nil)
		caster:RemoveModifierByName("modifier_thdots_kaguya02_Brilliant_Dragon_Bullet") 
		caster:SetContextNum("ability_kaguya02_swap_ability",2,0)
	elseif(abilityNumber==2)then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kaguya02_Salamander_Shield", nil)
		caster:RemoveModifierByName("modifier_thdots_kaguya02_Buddhist_Diamond") 
		caster:SetContextNum("ability_kaguya02_swap_ability",3,0)
	elseif(abilityNumber==3)then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kaguya02_Life_Spring_Infinity", nil)
		caster:RemoveModifierByName("modifier_thdots_kaguya02_Salamander_Shield") 
		caster:SetContextNum("ability_kaguya02_swap_ability",0,0)
	end
end

function OnKaguya02SpellDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		local damage_table = {
			    victim = v,
			    attacker = caster,
			    damage = keys.AbilityDamage/5,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
end

function OnKaguya03SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local dummy = CreateUnitByName(
		"npc_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	dummy:AddAbility("night_stalker_darkness") 
	local darkness = dummy:FindAbilityByName("night_stalker_darkness")
	darkness:SetLevel(1)
	dummy:CastAbilityImmediately(darkness, caster:GetPlayerOwnerID())
	dummy:RemoveSelf()
end

function OnKaguya03ManaRegen(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(GameRules:IsDaytime()==false)then
		local bonusMana = (keys.ManaRegen + keys.BonusRegen * GameRules:GetGameTime()/keys.increaseTime)/10
		caster:SetMana(caster:GetMana()+bonusMana)
	end
end