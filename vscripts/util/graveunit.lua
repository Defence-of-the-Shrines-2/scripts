	
	function UnitGraveTarget( caster,target )
		target:AddNewModifier(caster, nil, "dazzle_shallow_grave", {duration=9999})
    end