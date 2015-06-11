if AbilityYuyuko == nil then
	AbilityYuyuko = class({})
end

function OnYuyukoExSpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin() 
	local damageTaken = keys.DamageTaken
	local damage_table
	
	if(keys.ability:GetContext("abilityyuyuko_Ex_grave")==FALSE or keys.ability:GetContext("abilityyuyuko_Ex_grave")==nil)then
		UnitGraveTarget(caster,caster)
		keys.ability:SetContextNum("abilityyuyuko_Ex_grave", TRUE, 0) 
	end
	if(caster:GetHealth()<=5)then
		local attacker = EntIndexToHScript(keys.ability:GetContext("ability_yuyuko_Ex_attacker"))
		local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yuyuko/ability_yuyuko_04_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yuyuko/ability_yuyuko_04_effect_a.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 5, caster:GetOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		caster:SetHealth(caster:GetMaxHealth())
		UnitDisarmedTarget(caster,caster,keys.LifeDuration)
		UnitNoDamageTarget(caster,caster,keys.LifeDuration)
		caster:SetContextThink("abilityyuyuko_Ex_grave_timer", 
			function()
				caster:RemoveModifierByName("modifier_dazzle_shallow_grave")
				keys.ability:SetContextNum("abilityyuyuko_Ex_grave", FALSE, 0) 
				if(attacker~=nil)then
			    	damage_table = {
						victim = caster,
						attacker = attacker,
						damage = 99999,
						damage_type = DAMAGE_TYPE_PURE,
	    				damage_flags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE
					}
			    else
			    	caster:Kill(keys.ability, nil)
			    end
			    UnitDamageTarget(damage_table)
			end, 
			keys.LifeDuration+0.1) 
		Timer.Loop 'abilityyuyuko_Ex_unablemove_timer' (0.1, 100,
			function(i)
				if(GetDistanceBetweenTwoVec2D(caster:GetOrigin(),vecCaster)>300)then
					caster:SetOrigin(vecCaster)
				end
			end
		)
	end
end

function OnYuyukoExSpellOnDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local attacker = keys.attacker
	local vecCaster = caster:GetOrigin() 
	local damageTaken = keys.DamageTaken
	--PrintTable(keys)
	local damage_table
	local deadflag = caster:GetContext("ability_yuyuko_Ex_deadflag")

	if(deadflag==nil)then
		caster:SetContextNum("ability_yuyuko_Ex_deadflag",FALSE,0)
		deadflag = FALSE
	end
	
	if(caster:GetHealth()<=damageTaken and deadflag == FALSE )then
		local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yuyuko/ability_yuyuko_04_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)

		effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yuyuko/ability_yuyuko_04_effect_a.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 5, caster:GetOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)

		caster:SetHealth(caster:GetMaxHealth())
		UnitDisarmedTarget(caster,caster,keys.LifeDuration)
		UnitNoDamageTarget(caster,caster,keys.LifeDuration)
		caster:SetContextNum("ability_yuyuko_Ex_deadflag",TRUE,0)
		caster:SetContextThink("abilityyuyuko_Ex_undead_timer", 
			function()
				print("kill!")
				if(attacker~=nil)then
			    	damage_table = {
						victim = caster,
						attacker = attacker,
						damage = 99999,
						damage_type = DAMAGE_TYPE_PURE,
	    				damage_flags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE
					}
			    else
			    	caster:Kill(keys.ability, nil)
			    end
			    UnitDamageTarget(damage_table)
			    caster:SetContextNum("ability_yuyuko_Ex_deadflag",FALSE,0)
			end, 
			keys.LifeDuration+0.1) 
		Timer.Loop 'abilityyuyuko_Ex_unablemove_timer' (0.1, 100,
			function(i)
				if(GetDistanceBetweenTwoVec2D(caster:GetOrigin(),vecCaster)>300)then
					caster:SetOrigin(vecCaster)
				end
			end
		)
	end
end

function OnYuyuko04SpellStart(keys)
	PrintTable(keys)
end


function OnYuyuko04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local vecForward = caster:GetForwardVector() 
	local unit = CreateUnitByName(
		"npc_dota2x_unit_yuyuko_04"
		,caster:GetOrigin() - vecForward * 100
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	local forwardRad = GetRadBetweenTwoVec2D(caster:GetOrigin(),unit:GetOrigin())
	unit:SetForwardVector(Vector(math.cos(forwardRad+math.pi/2),math.sin(forwardRad+math.pi/2),0))

	local effectIndex2 = ParticleManager:CreateParticle("particles/heroes/yuyuko/ability_yuyuko_04_effect_d.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex2, 0, caster:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex2,false)

	unit:SetContextThink("ability_yuyuko_04_unit_remove", 
		function () 
			unit:RemoveSelf()
			return nil
		end, 
		2.0)

	keys.ability:SetContextNum("ability_yuyuko_04_time_count", keys.DamageCount, 0) 
end

function OnYuyuko04SpellRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
end

function OnYuyuko04SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targets = keys.target_entities

	local timecount = keys.ability:GetContext("ability_yuyuko_04_time_count")
	if(timecount>=0)then
		timecount = timecount - 1
		keys.ability:SetContextNum("ability_yuyuko_04_time_count", timecount, 0) 
		for _,v in pairs(targets) do    
			if((v:GetTeam()~=caster:GetTeam()) and (v:IsInvulnerable() == false) and (v:IsTower() == false) and (v:IsAlive() == true) and (v:GetClassname()~="npc_dota_roshan"))then
				local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yuyuko/ability_yuyuko_04_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, v:GetOrigin())
				ParticleManager:DestroyParticleSystem(effectIndex,false)

				effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yuyuko/ability_yuyuko_04_effect_a.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, v:GetOrigin())
				ParticleManager:SetParticleControl(effectIndex, 5, v:GetOrigin())
				ParticleManager:DestroyParticleSystem(effectIndex,false)

				local effectIndex2 = ParticleManager:CreateParticle("particles/heroes/yuyuko/ability_yuyuko_04_effect_d.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex2, 0, v:GetOrigin())
				ParticleManager:DestroyParticleSystem(effectIndex2,false)


				local vecV = v:GetOrigin()
				local deal_damage = (v:GetMaxHealth() - v:GetHealth())*keys.DamageMulti
				local boolDamage
				if((v:GetHealth()<=deal_damage) or (v:IsHero()==false))then
					boolDamage = true
				else
					boolDamage = false
				end

				if(v:IsHero()==false)then
					v:Kill(keys.ability,caster)
				else
					local damage_table = {
						victim = v,
						attacker = caster,
						damage = deal_damage,
						damage_type = keys.ability:GetAbilityDamageType(), 
						damage_flags = 0
					}
					UnitDamageTarget(damage_table)
				end

				if(boolDamage)then
					local DamageTargets = FindUnitsInRadius(
					   caster:GetTeam(),		--caster team
					   vecV,					--find position
					   nil,						--find entity
					   keys.DamageRadius,		--find radius
					   DOTA_UNIT_TARGET_TEAM_ENEMY,
					   keys.ability:GetAbilityTargetType(),
					   0, FIND_CLOSEST,
					   false
				    )
					for _,v in pairs(DamageTargets) do
					    local damage_table_death = {
							victim = v,
							attacker = caster,
							damage = keys.ability:GetAbilityDamage(),
							damage_type = keys.ability:GetAbilityDamageType(), 
							damage_flags = 0
						}
					    UnitDamageTarget(damage_table_death)
					end
				end

				

				return
			end
		end
	else
		caster:RemoveModifierByName("modifier_thdots_yuyuko04_think_interval") 
	end
end
