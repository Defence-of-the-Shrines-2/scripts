if AbilitySuika == nil then
	AbilitySuika = class({})
end


function OnSuika02Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		local deal_damage = keys.ability:GetAbilityDamage()
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

function OnSuika02ULTStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	local abilityLevel = caster:GetContext("ability_thdots_suika02_level") 
	for _,v in pairs(targets) do
		local deal_damage = 60 + (abilityLevel - 1) * 30
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

function OnSuika03Spawn(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local unit = CreateUnitByName(
		"npc_dota_suika_03_smallsuika"
		,caster:GetOrigin() - caster:GetForwardVector() * 100
		,false
		,caster
		,caster
		,caster:GetTeam()
		)
	unit:SetContextThink("npc_dota_suika_03_smallsuika_timer",
		function ()
			unit:RemoveSelf() 
			return nil
		end, 5.0) 
end

function OnSuika04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:SetModelScale(3.0)
	local ability = caster:FindAbilityByName("ability_thdots_suika02") 
	caster:SetContextNum("ability_thdots_suika02_level", ability:GetLevel(), 0) 
	caster:RemoveAbility("ability_thdots_suika02") 
	caster:RemoveModifierByName("passive_suika02_attack") 
	caster:AddAbility("ability_thdots_suika02_ult")
	local abilityUlt = caster:FindAbilityByName("ability_thdots_suika02_ult")
	abilityUlt:SetLevel(keys.ability:GetLevel())
	caster:SetContextThink("ability_thdots_suika04_duration", 
		function ()
			caster:RemoveAbility("ability_thdots_suika02_ult") 
			caster:AddAbility("ability_thdots_suika02")
			caster:RemoveModifierByName("passive_suika02_ult_attack") 
			local ability02 = caster:FindAbilityByName("ability_thdots_suika02")
			ability02:SetLevel(caster:GetContext("ability_thdots_suika02_level"))
			caster:SetModelScale(1.0)
		end
	, keys.Duration) 
end