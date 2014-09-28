function OnCollectionPower(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:SetContextNum("ability_collection_power_speed",2,0)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		if((v:GetUnitName()=="npc_coin_up_unit") or (v:GetUnitName()== "npc_power_up_unit"))then
			if(v:GetContext("ability_collection_power")==nil)then
				v:SetThink(
				function()
					OnCollectionPowerMove(v,caster)
					return 0.02
				end, 
				"ability_collection_power",
				0.02)
			end
		end
	end
end

function OnCollectionPowerMove(target,caster)
	local vecTarget = target:GetOrigin()
	local vecCaster = caster:GetOrigin()
	local speed = caster:GetContext("ability_collection_power_speed") + 1
	local radForward = GetRadBetweenTwoVec2D(vecTarget,vecCaster)
	local vecForward = Vector(math.cos(radForward) * speed,math.sin(radForward) * speed,1)
	vecTarget = vecTarget + vecForward
	
	target:SetOrigin(vecTarget)
	caster:SetContextNum("ability_collection_power_speed",speed,0)
	if(GetDistanceBetweenTwoVec2D(vecTarget,vecCaster)<50)then
		if((target:GetUnitName()=="npc_coin_up_unit"))then
			local effectIndex = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(effectIndex, 0, vecCaster)
			ParticleManager:SetParticleControl(effectIndex, 1, vecCaster)
			ParticleManager:ReleaseParticleIndex(effectIndex)
			local ply = caster:GetOwner()
			local playerId = ply:GetPlayerID()
			local modifyGold = PlayerResource:GetReliableGold(playerId) + 35
			PlayerResource:SetGold(playerId, modifyGold, true)
		elseif(target:GetUnitName()=="npc_power_up_unit")then
		    local powerCount = caster:GetContext("hero_bouns_stat_power_count")
			if(powerCount==nil)then
				caster:SetContextNum("hero_bouns_stat_power_count",0,0)
				powerCount = 0
			end
			if(powerCount<30)then
				local effectIndex = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_spotlight.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, vecCaster)
				ParticleManager:ReleaseParticleIndex(effectIndex)
				powerCount = powerCount + 1
				caster:SetContextNum("hero_bouns_stat_power_count",powerCount,0)
				if(caster:GetPrimaryAttribute()==0)then
					caster:SetBaseStrength(caster:GetBaseStrength()+1)
				elseif(caster:GetPrimaryAttribute()==1)then
					caster:SetBaseAgility(caster:GetBaseAgility()+1)
				elseif(caster:GetPrimaryAttribute()==2)then
					caster:SetBaseIntellect(caster:GetBaseIntellect()+1)
				end
			end
		end
		target:RemoveSelf()
	end
end