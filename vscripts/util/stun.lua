
    if UtilStun == nil then
	    UtilStun = class({})
    end

	function UtilStun:UnitStunTarget( caster,target,stuntime)
		target:AddNewModifier(caster, nil, "modifier_stunned", {duration=stuntime})
    end