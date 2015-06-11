
	function UnitPauseTarget( caster,target,pausetime)
		local dummy = CreateUnitByName("npc_dummy_unit", 
	    	                target:GetAbsOrigin(), 
							false, 
							caster, 
							caster, 
							caster:GetTeamNumber()
						)
		dummy:SetOwner(caster)
		dummy:AddAbility("ability_stunsystem_pause") 
		local ability = dummy:FindAbilityByName("ability_stunsystem_pause")
			
		ability:ApplyDataDrivenModifier( caster, target, "modifier_stunsystem_pause", {Duration=pausetime} )
   	end