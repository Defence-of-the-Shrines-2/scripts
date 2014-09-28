
    function UnitNoCollision( caster,target,duration)
    	print("start")
		if (target == nil) then
			return
		end
		
		--创建马甲单位
	    local dummy = CreateUnitByName("npc_dummy_unit", 
	    	                            target:GetAbsOrigin(), 
										false, 
										caster, 
										caster, 
										caster:GetTeamNumber()
										)
     	dummy:SetOwner(caster)
    	dummy:AddAbility("ability_system_collision") 
		--寻找单位释放技能
    	local BUFF_TARGET = dummy:FindAbilityByName("ability_system_collision")
		
	    dummy:CastAbilityOnTarget(target, BUFF_TARGET, 0 )
		target:SetContextThink(DoUniqueString('ability_system_collision'),
    	function ()
		        target:RemoveModifierByName("modifier_system_collision")
                dummy:RemoveSelf()
	    	    return nil
		end,duration)
    end