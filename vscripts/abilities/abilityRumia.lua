--keys.caster --施法者
--keys.target_entities -- 目标表
--keys.ability --技能
function OnRumia02BloodDamage( keys )
	if keys.target ~= nil then
		local caster = EntIndexToHScript(keys.caster_entindex)
		local target = keys.target
		--[[local al = keys.ability:GetLevel() - 1
		damage = keys.ability:GetLevelSpecialValueFor("damage", al)]]--
	    local DamageTable = {
							    victim = target, 
							    attacker = caster, 
							    damage = keys.dv,
							    damage_type = keys.ability:GetAbilityDamageType(),
							    damage_flags = 0
							}
	    UnitDamageTarget(DamageTable)
	  end
    print("----------------------------------OnRumia02BloodDamage-------------------------------------------------------")
end

function OnRumia02Blood(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if keys.target ~= nil then
		if not target:IsMechanical() and not target:IsAncient() then
			Timer.Loop 'Rumia_Blood' (keys.ti,keys.dc,
								    function(i)
								    	print(i)
								    	print(target)
								    	print("yes i m")
								    	print(caster)
								    	print(keys.dv)
								    	print(keys.ability:GetAbilityDamageType())

							            local DamageTable = {
											                    victim = target, 
											                    attacker = caster, 
											                    damage = keys.dv, 
											                    damage_type = keys.ability:GetAbilityDamageType(),
											                    damage_flags = 0
															}
					    				UnitDamageTarget(DamageTable)
					                    if i == keys.dc then
					                    	print("i m out")
					                    	--以下的语句为继续执行
					                    	--return true
										end
					                    --伤害次数
										--[[local count = v:GetContext("Reimu04_Effect_Damage_Count")
										count = count - 1
										--每次减一
										if (count<=0) then
											v:SetContextNum("Reimu04_Effect_Damage_Count" , 0, 0)
											return nil
											--小于0清0滚粗返空解除
										else
										    if(v~=nil)then
												v:SetContextNum("Reimu04_Effect_Damage_Count" , count, 0)
											end
											--大于0继续
										end]]--
								    end
							        )
		end
	end
	print("----------------------------------OnRumia02Blood-------------------------------------------------------")
end
function OnRumia04Start(keys)
	if keys.target ~= nil then
		local caster = EntIndexToHScript(keys.caster_entindex)
		local target = keys.target

		if(caster:GetContext("Rumia04_Strength_Up")==nil)then
				caster:SetContextNum("Rumia04_Strength_Up",0,0)
		end
		local Rumia_Strength_Up = caster:GetContext("Rumia04_Strength_Up")
		local DamageTable= {
								victim = target,
								attacker = caster,
								damage = keys.ability:GetAbilityDamage(),
								damage_type = DAMAGE_TYPE_PURE,
							}
		if target:IsHero() ==false then
			DamageTable.damage = 99999
		end


	    if (caster:GetTeam() ~= target:GetTeam())then
	    	print("team trigger")
	    	if target:GetHealth() <= keys.ability:GetAbilityDamage()  then
	    		print("GetHealth trigger")
	    		local strength = 0
	    		if target:IsHero() then
	    			print("IsHero")
	    			if not target:IsIllusion()	then
	    				print("not IsIllusion")
	    				Rumia_Strength_Up = Rumia_Strength_Up + 5
	    				strength = 5
	    			end
	    		else
	    			print("else not IsHero")
	    			Rumia_Strength_Up = Rumia_Strength_Up + 1
	    			strength = 1
	    		end
	    		print(caster:GetHealth() + keys.ability:GetAbilityDamage()*keys.StealHealth)
				caster:SetHealth(caster:GetHealth() + target:GetHealth()*keys.StealHealth)
	    		caster:SetContextNum("Rumia04_Strength_Up",Rumia_Strength_Up,0)
	    		caster:SetBaseStrength(caster:GetBaseStrength() + strength)
	    	else
	    		caster:SetHealth(caster:GetHealth() + keys.ability:GetAbilityDamage()*keys.StealHealth)
	    	end
	    	UnitDamageTarget(DamageTable)
	    end
	end
    print("----------------------------------OnRumia04Start-------------------------------------------------------")
end
function OnRumiaDead(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	print(caster)
	if caster ~= nil then
		local Rumia_Strength_Up = caster:GetContext("Rumia04_Strength_Up")
		if Rumia_Strength_Up <= 0 then return end	
		local strengthDown = Rumia_Strength_Up*keys.LostStrength
		Rumia_Strength_Up = Rumia_Strength_Up - strengthDown
		caster:SetContextNum("Rumia04_Strength_Up",Rumia_Strength_Up,0)
		caster:SetBaseStrength(caster:GetBaseStrength() - strengthDown)
	end
	print("----------------------------------OnRumiaDead-------------------------------------------------------")
end