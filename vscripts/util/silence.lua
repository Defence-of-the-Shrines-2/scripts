
    if UtilSilence == nil then
	    UtilSilence = class({})
    end

    function UtilSilence:UnitSilenceTarget( caster,target,sliencetime)
		if (target:GetContext("ability_sliencesystem_Silence_duration")==nil) then
			target:SetContextNum("ability_sliencesystem_Silence_duration",0,0)
		end
		local old_stun_duration = target:GetContext("ability_sliencesystem_Silence_duration")
		local stun_duration = math.max(old_stun_duration,sliencetime)
		target:SetContextNum("ability_sliencesystem_Silence_duration",stun_duration,0)
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
			dummy:AddAbility("ability_sliencesystem_Silence") 
			--寻找单位释放技能
			local STUN_TARGET = dummy:FindAbilityByName("ability_sliencesystem_Silence")
			
			dummy:CastAbilityOnTarget(target, STUN_TARGET, 0 )
			target:SetContextThink('ability_sliencesystem_Silence',
				function ()
					local systemStunDuration = target:GetContext("ability_sliencesystem_Silence_duration")
					if(systemStunDuration>0)then
						systemStunDuration = systemStunDuration - 0.1
						target:SetContextNum("ability_sliencesystem_Silence_duration",systemStunDuration,0)
						return 0.1
					end
					target:SetContextNum("ability_sliencesystem_Silence_duration",0,0)
					target:RemoveModifierByName("modifier_sliencesystem_silence")
					dummy:RemoveSelf()
					return nil
				end,0.1)
		end
    end