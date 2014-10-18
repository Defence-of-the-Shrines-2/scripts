
    if UtilStun == nil then
	    UtilStun = class({})
    end

	function UtilStun:UnitStunTarget( caster,target,stuntime)
		if (target:GetContext("ability_stunsystem_stun_duration")==nil) then
			target:SetContextNum("ability_stunsystem_stun_duration",0,0)
		end
		local old_stun_duration = target:GetContext("ability_stunsystem_stun_duration")
		local stun_duration = math.max(old_stun_duration,stuntime)
		target:SetContextNum("ability_stunsystem_stun_duration",stun_duration,0)
		if(old_stun_duration==0)then
			--创建马甲单位
			local dummy = CreateUnitByName("npc_dummy_unit", 
	    	                            target:GetAbsOrigin(), 
										false, 
									    caster, 
										caster, 
										caster:GetTeamNumber()
										)
			dummy:SetOwner(caster)
			dummy:AddAbility("ability_stunsystem_stun") 
			--寻找单位释放技能
			local STUN_TARGET = dummy:FindAbilityByName("ability_stunsystem_stun")
			
			dummy:CastAbilityOnTarget(target, STUN_TARGET, 0 )
			target:SetContextThink('ability_stunsystem_stun',
				function ()
					local systemStunDuration = target:GetContext("ability_stunsystem_stun_duration")
					if(systemStunDuration>0)then
						systemStunDuration = systemStunDuration - 0.1
						target:SetContextNum("ability_stunsystem_stun_duration",systemStunDuration,0)
						return 0.1
					end
					target:SetContextNum("ability_stunsystem_stun_duration",0,0)
					target:RemoveModifierByName("modifier_stunsystem_stun")
					dummy:RemoveSelf()
					return nil
				end,0.1)
		end
    end