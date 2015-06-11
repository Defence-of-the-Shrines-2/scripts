if AbilityReisen == nil then
	AbilityReisen = class({})
end

function OnReisenExSpellStart(caster,target)
	for i=1,2 do
		local rad = RandomFloat(-math.pi,math.pi)
		local dis = RandomFloat(400,700)
		local unit = CreateUnitByName(
			"npc_thdots_unit_reisenEx_unit"
			,target:GetOrigin() + Vector(dis*math.cos(rad),dis*math.sin(rad),0)
			,false
			,caster
			,caster
			,caster:GetTeam()
		)
		unit:MoveToTargetToAttack(target)
		unit:SetContextThink("ability_reisen_ex_spell_think", 
			function ()
				unit:ForceKill(true)
			end, 
		2)
	end
end

function OnReisen01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	local Reisen01rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	keys.ability:SetContextNum("ability_Reisen01_Rad",Reisen01rad,0)
end

function OnReisen01SpellMove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	local Reisen01rad = keys.ability:GetContext("ability_Reisen01_Rad")

	local vec = Vector(vecCaster.x-math.cos(Reisen01rad)*keys.MoveSpeed/50,vecCaster.y-math.sin(Reisen01rad)*keys.MoveSpeed/50,vecCaster.z)
	caster:SetOrigin(vec)
end

function OnReisen01SpellHit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local damage_table = {
			    victim = keys.target,
			    attacker = caster,
			    damage = keys.ability:GetAbilityDamageType(),
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
	}
	UnitDamageTarget(damage_table)
	if(caster:GetContext("ability_reisen02_buff")==TRUE)then
		local targets = FindUnitsInRadius(
		   	caster:GetTeam(),		--caster team
		  	keys.target:GetOrigin(),		--find position
		   	nil,					--find entity
		    caster:GetContext("ability_reisen02_buff_radius"),		--find radius
		   	DOTA_UNIT_TARGET_TEAM_ENEMY,
		   	keys.ability:GetAbilityTargetType(),
		   	0, 
		   	FIND_CLOSEST,
		   	false
	    )
	    OnReisen02FireEffect(keys.target)
	    OnReisen02DealDamage(caster,targets)
	end

	OnReisenExSpellStart(caster,keys.target)

	SetTargetToTraversable(caster)
end

function OnReisen02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:SetContextNum("ability_reisen02_buff",TRUE,0)
	caster:SetContextNum("ability_reisen02_buff_damage",keys.BounsDamage,0)
	caster:SetContextNum("ability_reisen02_buff_stun_duration",keys.Duration,0)
	caster:SetContextNum("ability_reisen02_buff_radius",keys.Radius,0)
	caster:SetContextNum("ability_reisen02_buff_type",keys.ability:GetAbilityDamageType(),0)
	caster:SetContextNum("ability_reisen02_buff_flag",keys.ability:GetAbilityTargetFlags(),0)
	caster:SetContextThink("ability_reisen02_buff_timer", 
		function()
			caster:SetContextNum("ability_reisen02_buff",FALSE,0)
			return nil
		end, 
	keys.AbilityDuration)
end

function OnReisen02DealDamage(caster,targets)
	for _,v in pairs(targets) do
		local damage_table = {
			victim = v,
			attacker = caster,
			damage = caster:GetContext("ability_reisen02_buff_damage"),
			damage_type = caster:GetContext("ability_reisen02_buff_type"), 
			damage_flags = caster:GetContext("ability_reisen02_buff_flag")
		}

		--OnReisenExSpellStart(caster,v)
		UnitDamageTarget(damage_table)
		UtilStun:UnitStunTarget( caster,v,caster:GetContext("ability_reisen02_buff_stun_duration") )
	end	
end

function OnReisen02FireEffect(v)
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_target.vpcf", PATTACH_CUSTOMORIGIN, v)
	ParticleManager:SetParticleControlEnt(effectIndex, 0, v, 0, follow_origin, v:GetOrigin(), false)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
end

function OnReisen03SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	local reisen03rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint) + math.pi/3
	local reisen03dis = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/reisen/ability_reisen_01_e.vpcf", PATTACH_CUSTOMORIGIN, caster)
	local originVector = caster:GetOrigin() + Vector(math.cos(reisen03rad- math.pi/75)*reisen03dis,math.sin(reisen03rad- math.pi/75)*reisen03dis,0)

	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_eye", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effectIndex, 1, originVector)
	ParticleManager:SetParticleControlEnt(effectIndex , 9, caster, 5, "attach_eye", Vector(0,0,0), true)
	
	
	keys.ability:SetContextNum("ability_reisen03_Rad",reisen03rad,0)
	keys.ability:SetContextNum("ability_reisen03_dis",reisen03dis,0)
	keys.ability:SetContextNum("ability_reisen03_effectIndex",effectIndex,0)

	UnitPauseTarget( caster,caster,1.0)
end


function OnReisen03SpellMove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	local originRad = keys.ability:GetContext("ability_reisen03_Rad")
	local originVector = Vector(math.cos(originRad),math.sin(originRad),0)
	local originDis = keys.ability:GetContext("ability_reisen03_dis")
	
	for _,v in pairs(targets) do
		local vecV = v:GetOrigin()
		if(IsRadInRect(vecV,vecCaster,100,originDis,originRad))then
			local damage_table = {
			    victim = v,
			    attacker = caster,
			   	damage = keys.ability:GetAbilityDamage(),
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	   	damage_flags = 0
			}
			OnReisen03DamageTarget(damage_table)
		end
	end
	local effectIndex = keys.ability:GetContext("ability_reisen03_effectIndex")
	local originRad = originRad - math.pi/75
	caster:SetForwardVector(Vector(math.cos(originRad)*originDis,math.sin(originRad)*originDis,0))
	local forwardVec = caster:GetForwardVector()
	keys.ability:SetContextNum("ability_reisen03_Rad",originRad,0)

	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetOrigin() + Vector(math.cos(originRad)*originDis,math.sin(originRad)*originDis,0))
	
	ParticleManager:DestroyParticleSystem(effectIndex,false)
end

function OnReisen03DamageTarget(damage_table)
	local caster = damage_table.attacker
	local target = damage_table.victim
	if(target:GetContext("ability_reisen03_damage_tag")==nil or target:GetContext("ability_reisen03_damage_tag")==FALSE)then
		target:SetContextNum("ability_reisen03_damage_tag",TRUE,0)
		Timer.Wait 'ability_reisen03_damage_tag' (1,
			function()
				OnReisenExSpellStart(caster,target)
				UnitDamageTarget(damage_table)
				
				if(caster:GetContext("ability_reisen02_buff")==TRUE)then
					local targets = FindUnitsInRadius(
					   	caster:GetTeam(),		--caster team
					  	target:GetOrigin(),		--find position
					   	nil,					--find entity
					   	caster:GetContext("ability_reisen02_buff_radius"),		--find radius
					   	DOTA_UNIT_TARGET_TEAM_ENEMY,
					   	damage_table.damage_type,
					   	0, 
					   	FIND_CLOSEST,
					   	false
				    )
				    OnReisen02FireEffect(target)
				    OnReisen02DealDamage(caster,targets)
				end

				target:SetContextNum("ability_reisen03_damage_tag",FALSE,0)
			end
		)
	end
end

function OnReisen04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local OnHitFuction = "OnReisen04ProjectileOnHit"
	local forwardVec = caster:GetForwardVector()
	local forwardCos = forwardVec.x
	local forwardSin = forwardVec.y

	for i=1,5 do
		local rollRad = math.pi/6 * i - math.pi/2
		local shotVector =  Vector(math.cos(rollRad)*forwardCos - math.sin(rollRad)*forwardSin,
								 forwardSin*math.cos(rollRad) + forwardCos*math.sin(rollRad),
								 0)
		local BulletTable = {
		    Ability        	 	=   keys.ability,
			EffectName			=	"particles/heroes/reisen/ability_reisen_04_bullet.vpcf",
			vSpawnOrigin		=	caster:GetOrigin() + Vector(0,0,64),
			fDistance			=	1500,
			fStartRadius		=	keys.DamageRadius,
			fEndRadius			=	keys.DamageRadius,
			Source         	 	=   caster,
			bHasFrontalCone		=	false,
			bRepalceExisting 	=  false,
			iUnitTargetTeams		=	"DOTA_UNIT_TARGET_TEAM_ENEMY",
			iUnitTargetTypes		=	"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_CREEP",
			iUnitTargetFlags		=	"DOTA_UNIT_TARGET_FLAG_NONE",
			fExpireTime     =   GameRules:GetGameTime() + 10.0,
			bDeleteOnHit    =   true,
			vVelocity       =   shotVector,
			bProvidesVision	=	true,
			iVisionRadius	=	400,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		DotsCreateProjectileMoveToTargetPoint(BulletTable,caster,keys.MoveSpeed,keys.Acceleration1,keys.Acceleration2,OnHitFuction)
	end
end

function OnReisen04ProjectileOnHit(caster,targets,ability)
    local damage_table = {
        victim = targets[1],
        attacker = caster,
        damage = ability:GetAbilityDamage(),
        damage_type = ability:GetAbilityDamageType(),
        damage_flags = ability:GetAbilityTargetFlags()
    }
    OnReisenExSpellStart(caster,targets[1])
    UnitDamageTarget(damage_table)
    if(caster:GetContext("ability_reisen02_buff")==TRUE)then
		local targets02 = FindUnitsInRadius(
		   	caster:GetTeam(),		--caster team
		  	targets[1]:GetOrigin(),		--find position
		   	nil,					--find entity
		    caster:GetContext("ability_reisen02_buff_radius"),		--find radius
		   	DOTA_UNIT_TARGET_TEAM_ENEMY,
		   	ability:GetAbilityTargetType(),
		   	0, 
		   	FIND_CLOSEST,
		   	false
	    )
	    OnReisen02FireEffect(targets[1])
	    OnReisen02DealDamage(caster,targets02)
	end
end


function DotsCreateProjectileMoveToTargetPoint(projectileTable,caster,speed,acceleration1,acceleration2,OnHitFuction)
    local effectIndex = ParticleManager:CreateParticle(projectileTable.EffectName, PATTACH_CUSTOMORIGIN, caster)
    local acceleration = acceleration1
    local targets = {}
    caster:SetContextThink(DoUniqueString("ability_caster_projectile"), 
        function()
            local vec = projectileTable.vSpawnOrigin + projectileTable.vVelocity*speed/50
            local dis = GetDistanceBetweenTwoVec2D(projectileTable.vSpawnOrigin,vec)
            targets = FindUnitsInRadius(
                caster:GetTeam(),       --caster team
                vec,                    --find position
                nil,                    --find entity
                projectileTable.fStartRadius,       --find radius
                projectileTable.Ability:GetAbilityTargetTeam(),
                projectileTable.Ability:GetAbilityTargetType(),
                projectileTable.Ability:GetAbilityTargetFlags(), 
                FIND_CLOSEST,
                false
            )
            if(targets[1]~=nil)then
                if(projectileTable.bDeleteOnHit)then
                    if(OnHitFuction=="OnReisen04ProjectileOnHit")then
                        OnReisen04ProjectileOnHit(caster,targets,projectileTable.Ability)
                    end
                    ParticleManager:DestroyParticleSystem(effectIndex,true)
                    return nil
                else
                    if(OnHitFuction=="OnReisen04ProjectileOnHit")then
                        OnReisen04ProjectileOnHit(caster,targets,projectileTable.Ability)
                    end
                    targets = {}
                end
            end

            if(speed <= 0 and acceleration2 ~= 0)then
                acceleration = acceleration2
                speed = 0
                acceleration2 = 0
            end

            if(dis<projectileTable.fDistance)then
                    ParticleManager:SetParticleControl(effectIndex,3,vec)
                    projectileTable.vSpawnOrigin = vec
                    speed = speed + acceleration
                    return 0.02
            else
                ParticleManager:DestroyParticleSystem(effectIndex,true)
                return nil
            end
        end, 
    0.02)
end