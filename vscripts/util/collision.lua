
    function UnitNoCollision( caster,target,duration)
		target:AddNewModifier(caster, nil, "modifier_phased", {duration=duration})
    end