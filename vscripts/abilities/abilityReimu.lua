-- Reimu01
-- init Ball parameters

REIMU01_GRAVITY = 10

REIMU02_FOLLOW_RADIUS = 650
REIMU02_DAMAGE_RADIUS = 50
REIMU02_LIGHTSPEED = 70

if AbilityReimu == nil then
	AbilityReimu = class({})
end

function OnReimu01SpellStart(keys)
	AbilityReimu:OnReimu01Start(keys)
end

function OnReimu01ReleaseBall(keys)
	AbilityReimu:OnReimu01Release(keys)
end

function OnReimu02SpellStart(keys)
	AbilityReimu:OnReimu02Start(keys)
end

function OnReimu02OnLightStart(keys)
	AbilityReimu:OnReimu02OnLight(keys)
end

function OnReimu03SpellStart(keys)
	AbilityReimu:OnReimu03Start(keys)
end

function OnReimu04SpellStart(keys)
	AbilityReimu:OnReimu04Start(keys)
end

function OnReimu04SpellThink(keys)
	AbilityReimu:OnReimu04Think(keys)
end


-- ³õÊ¼»¯ÁéÃÎµÄÒõÑôÓñºÍÎïÀí³£Á¿
--    t=ÔË¶¯Ê±¼ä
--    g=ÖØÁ¦¼ÓËÙ¶È
--    v=µ±Ç°ËÙ¶È
function AbilityReimu:initBallData()
	self.tReimu01Elements = {}
	for i = 0,9 do
		self.tReimu01Elements[i] = {
			Ball = {unit = nil , paIndex = nil , t = 0, g = REIMU01_GRAVITY, v = 0},
			Target = nil,
			Decrease = 0,
			OriginZ = 0,
		}
	end
end

function AbilityReimu:OnReimu01Start(keys)
	-- ³õÊ¼»¯³£Á¿
	self:initBallData()
	
	
	-- »ù´¡Êý¾Ý»ñÈ¡
	local targetPoint = keys.target_points[1]
	local caster = EntIndexToHScript(keys.caster_entindex)
	local nPlayerID = keys.unit:GetPlayerID()
	local FireIndex = ParticleManager:CreateParticle("particles/thd2/heroes/reimu/reimu_01_effect_fire.vpcf", PATTACH_CUSTOMORIGIN, caster)
	caster:SetContextNum("Reimu01_Effect_Fire_Index" , FireIndex, 0)
	
	-- Èç¹ûÇò´æÔÚÔòreturn
	if self.tReimu01Elements[nPlayerID].Ball.unit ~= nil then 
		return 
	end
	
	-- ´´½¨ÇòÌØÐ§
	local unit = CreateUnitByName(
		"npc_dota2x_unit_reimu01_ball"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
		)
		
	--»ñÈ¡µØÃæZÖá×ø±ê
	self.tReimu01Elements[nPlayerID].OriginZ = GetGroundPosition(targetPoint,nil).z
	if unit then
		self.tReimu01Elements[nPlayerID].Ball.unit = unit
		local diffVec = targetPoint - caster:GetOrigin()
		--unit:SetForwardVector(diffVec:Normalized())
		local vec3 = Vector(targetPoint.x,targetPoint.y,self.tReimu01Elements[nPlayerID].OriginZ+300)
		unit:SetOrigin(vec3)
	end
end

function AbilityReimu:OnReimu01Release( keys )
	local caster = EntIndexToHScript(keys.caster_entindex)
	local nPlayerID = caster:GetPlayerID()
	local uHead = self.tReimu01Elements[nPlayerID].Ball.unit
	if( uHead == nil )then
		return
	end
	local headOrigin = uHead:GetOrigin()
	
	self.tReimu01Elements[nPlayerID].Ball.t = self.tReimu01Elements[nPlayerID].Ball.t + 0.1
	local ut = self.tReimu01Elements[nPlayerID].Ball.t
	local ug = self.tReimu01Elements[nPlayerID].Ball.g
	self.tReimu01Elements[nPlayerID].Ball.v = self.tReimu01Elements[nPlayerID].Ball.v + ug
	local uv = self.tReimu01Elements[nPlayerID].Ball.v
	local uz = headOrigin.z - uv
	local vec = Vector(headOrigin.x,headOrigin.y,uz)
	local locability = keys.ability
	local abilitylevel = locability:GetLevel()
		
	local fireIndex = caster:GetContext("Reimu01_Effect_Fire_Index")
	ParticleManager:SetParticleControl(fireIndex, 0, vec)
	uHead:SetOrigin(vec)
	if uz <= self.tReimu01Elements[nPlayerID].OriginZ+80 then
		local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/reimu/reimu_01_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vec)
		ParticleManager:SetParticleControl(effectIndex, 2, vec)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		self.tReimu01Elements[nPlayerID].Ball.v = self.tReimu01Elements[nPlayerID].Ball.v / math.sqrt(1.5) * -1
		vec = Vector(headOrigin.x,headOrigin.y,self.tReimu01Elements[nPlayerID].OriginZ+80.1)
		uHead:SetOrigin(vec)
		local DamageTargets = FindUnitsInRadius(
		   caster:GetTeam(),		--caster team
		   uHead:GetOrigin(),		--find position
		   nil,					--find entity
		   keys.Radius,		--find radius
		   DOTA_UNIT_TARGET_TEAM_ENEMY,
		   keys.ability:GetAbilityTargetType(),
		   0, FIND_CLOSEST,
		   false
	    )
		local decrease = self.tReimu01Elements[nPlayerID].Decrease
		for _,v in pairs(DamageTargets) do
		   local DamageTable = {
	                victim = v, 
	                attacker = caster, 
	                damage = keys.ability:GetAbilityDamage() * (1-decrease), 
	                damage_type = keys.ability:GetAbilityDamageType(), 
	                damage_flags = 1
           }
		   UnitDamageTarget(DamageTable)
		   UtilStun:UnitStunTarget(caster,v,keys.StunDuration)
		end
		self.tReimu01Elements[nPlayerID].Decrease = self.tReimu01Elements[nPlayerID].Decrease + keys.DamageDecrease
		uHead:EmitSound("Visage_Familar.StoneForm.Cast")
	end
	
	if ut >= 2.6 then
		self.tReimu01Elements[nPlayerID].Ball.g = REIMU01_GRAVITY
		self.tReimu01Elements[nPlayerID].Ball.t = 0
		self.tReimu01Elements[nPlayerID].Ball.v = 0
		self.tReimu01Elements[nPlayerID].Decrease = 0
		self.tReimu01Elements[nPlayerID].Ball.OriginZ = 0
		uHead:RemoveSelf()
		
		self.tReimu01Elements[nPlayerID].Ball.unit = nil
	end
end
-- Reimu01End

--Reimu02
function AbilityReimu:initLightData(level)
	self.tReimu02Light = self.tReimu02Light or {}
	zincrease = REIMU02_LIGHTSPEED
	for i = 0,level+2 do
		self.tReimu02Light[i] = {
			Ball = {unit = nil , t = 0 },
			Target = nil,
		}
	end
end

function AbilityReimu:OnReimu02Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vec0 = caster:GetOrigin()
	local ability = keys.ability
	local abilitylevel = ability:GetLevel()
	
	
	AbilityReimu:initLightData(abilitylevel)

	for i = 0,abilitylevel+2 do
		local veccre = Vector(vec0.x + math.cos(0.628 * i) * 60 ,vec0.y + math.sin(0.628 * i) * 60 ,500)
		self.tReimu02Light[i].Ball.unit = CreateUnitByName(
			"npc_dota2x_unit_reimu02_light"
			,vec0
			,false
			,caster
			,caster
			,caster:GetTeam()
		)
		local removeUnit = self.tReimu02Light[i].Ball.unit
		removeUnit:SetContextThink("ability_reimu02_unit_remove",
			function()
				removeUnit:RemoveSelf()
				return nil
			end,5
		)
		
		if self.tReimu02Light[i].Ball.unit then
			self.tReimu02Light[i].Ball.unit:SetOrigin(veccre)
		else
		    self.tReimu02Light[i].Ball.unit = nil 
		end
	end
end

function AbilityReimu:OnReimu02OnLight (keys)
	local i = 0
	local caster = EntIndexToHScript(keys.caster_entindex)
	local level = keys.ability:GetLevel()
	self.tReimu02Light[i].Ball.t = self.tReimu02Light[i].Ball.t + 0.1
	
	if (self.tReimu02Light[i].Ball.t >= 2.9) then
		for i = 0,level+2 do
			if(self.tReimu02Light[i].Ball.unit ~= nil)then
		        self.tReimu02Light[i].Ball.unit:RemoveSelf()
		        self.tReimu02Light[i].Ball.unit = nil
			end
		end
		return
	end
	--ÉÏÏÂÌø¶¯
	for i = 0,level+2 do
		if (self.tReimu02Light[i].Ball.unit ~= nil) then
		
		    local vec = self.tReimu02Light[i].Ball.unit:GetOrigin()
		    local DamageTargets = FindUnitsInRadius(
		       caster:GetTeam(),		--caster team
		       vec,		--find position
		       nil,					--find entity
	    	   REIMU02_DAMAGE_RADIUS,		--find radius
	    	   DOTA_UNIT_TARGET_TEAM_ENEMY,
	    	   keys.ability:GetAbilityTargetType(),
	    	   0, FIND_CLOSEST,
	    	   false
	        )
		    for k,v in pairs(DamageTargets) do
			   if (v ~= nil) then
				   local DamageTable = {
	                    victim = v, 
	                    attacker = caster, 
	                    damage = keys.ability:GetAbilityDamage(), 
	                    damage_type = keys.ability:GetAbilityDamageType(), 
	                    damage_flags = 1
                   }
				   v:EmitSound("Hero_Wisp.Spirits.Target")
				   UnitDamageTarget(DamageTable)
				   self.tReimu02Light[i].Ball.unit:RemoveSelf()
				   self.tReimu02Light[i].Ball.unit = nil
		           break
			   end
		    end
			
			if (self.tReimu02Light[i].Ball.unit~= nil) then
					
			    local FollowTargets = FindUnitsInRadius(
		          caster:GetTeam(),		--caster team
		          vec,		--find position
		          nil,					--find entity
		          REIMU02_FOLLOW_RADIUS,		--find radius
		          DOTA_UNIT_TARGET_TEAM_ENEMY,
				  keys.ability:GetAbilityTargetType(),
		          0, FIND_CLOSEST,
		          false
	            )
			
			    local FollowTarget = nil
			
		        for k,v in pairs(FollowTargets) do
				   if (v == nil) then
		             self.tReimu02Light[i].Ball.unit:RemoveSelf()
				     self.tReimu02Light[i].Ball.unit = nil
		             break
			       else
				     FollowTarget = v
				     break
				   end
				end
				
				if (FollowTarget ~= nil) then
					
		            local vecenemy = FollowTarget:GetOrigin()
		
		            local radian = GetRadBetweenTwoVec2D(vec,vecenemy)
		   
		            vec.x = math.cos(radian) * REIMU02_LIGHTSPEED + vec.x
		            vec.y = math.sin(radian) * REIMU02_LIGHTSPEED + vec.y
		
			   end 
		   end
		   if vec.z>=500 then
				local ranInt = RandomInt(-20,-50)
				self.zincrease = ranInt
			end
			
		    if vec.z<=400 then
		    	local ranInt = RandomInt(20,50)
			    self.zincrease = ranInt
		    end
			
		    vec = Vector(vec.x + self.zincrease,vec.y + self.zincrease,vec.z + self.zincrease)
			if (self.tReimu02Light[i].Ball.unit~=nil)then
		    	self.tReimu02Light[i].Ball.unit:SetOrigin(vec) 
		    end
		end
	end
end
-- Reimu02End

function AbilityReimu:OnReimu03Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(caster:GetTeam() == keys.target:GetTeam())then
		keys.target:SetPhysicalArmorBaseValue(keys.target:GetPhysicalArmorBaseValue() + 99999)	
		keys.target:SetContextThink(DoUniqueString('SetPhysicalArmor99999'),
    	function ()
			keys.target:SetPhysicalArmorBaseValue(keys.target:GetPhysicalArmorBaseValue() - 99999)	
			keys.target:RemoveModifierByName("modifier_ability_dota2x_reimu03_effect")
			return nil
    	end,keys.Duration)
	else
	    UtilSilence:UnitSilenceTarget(caster,keys.target,keys.Duration)
		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('Release Effect'),
    	function ()
			keys.target:RemoveModifierByName("modifier_ability_dota2x_reimu03_effect")
	    	return nil
    	end,keys.Duration)
	end
end

function AbilityReimu:OnReimu04Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local unit = CreateUnitByName(
		"npc_reimu_04_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	local nEffectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/reimu/reimu_04_effect.vpcf",PATTACH_CUSTOMORIGIN,unit)
	local vecCorlor = Vector(255,0,0)
	ParticleManager:SetParticleControl( nEffectIndex, 0, caster:GetOrigin())
	ParticleManager:SetParticleControl( nEffectIndex, 1, caster:GetOrigin())
	ParticleManager:SetParticleControl( nEffectIndex, 2, vecCorlor)
	ParticleManager:SetParticleControl( nEffectIndex, 3, caster:GetForwardVector())
	ParticleManager:SetParticleControl( nEffectIndex, 4, caster:GetOrigin())
	ParticleManager:SetParticleControl( nEffectIndex, 5, caster:GetOrigin())
	
	unit:SetOwner(caster)
	--unit:AddAbility("ability_dota2x_reimu04_unit")
	local unitAbility = unit:FindAbilityByName("ability_dota2x_reimu04_unit")
	unitAbility:SetLevel(keys.ability:GetLevel())
	unit:CastAbilityImmediately(unitAbility,0)
		
	caster:SetContextNum("Reimu04_Effect_Unit" , unit:GetEntityIndex(), 0)
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('ability_reimu04_damage'),
    	function ()
		    if (unit~=nil) then
		        unit:RemoveSelf()
		    	return nil
			end
	    end,keys.Ability_Duration+0.1)
end

function AbilityReimu:OnReimu04Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local Targets = keys.target_entities

	for k,v in pairs(Targets) do
		if(v:GetTeam() == caster:GetTeam())then
			if(v:GetContext("Reimu04_Effect_MAGIC_IMMUNE")~=0) then
			    v:SetContextNum("Reimu04_Effect_MAGIC_IMMUNE" , 0, 0)
			    UnitMagicImmune(caster,v,keys.Ability_Duration)
				v:SetContextThink(DoUniqueString('ability_reimu04_magic_immune'),
				function ()
				    if (v~=nil) then
		                v:SetContextNum("Reimu04_Effect_MAGIC_IMMUNE" , 1, 0)
					    return nil
				    end
		        end,keys.Ability_Duration)
			end
		else
			if(v:GetContext("Reimu04_Effect_Damage")==nil)then
			    v:SetContextNum("Reimu04_Effect_Damage" , 1, 0)
				v:SetContextNum("Reimu04_Effect_Damage_Count" , keys.Damage_Count, 0)
			end
			
			if(v:GetContext("Reimu04_Effect_Damage")==1)then
				v:SetContextNum("Reimu04_Effect_Damage" , 0, 0)
				v:SetContextThink(DoUniqueString('ability_reimu04_damage'),
    	        function ()
				    v:SetContextNum("Reimu04_Effect_Damage" , 1, 0)
					v:SetContextNum("Reimu04_Effect_Damage_Count" , keys.Damage_Count, 0)
				end,keys.Ability_Duration)
				
				local DamageTable = {
	                victim = v, 
	                attacker = caster, 
	                damage = keys.ability:GetAbilityDamage()/keys.Damage_Count, 
	                damage_type = keys.ability:GetAbilityDamageType(), 
	                damage_flags = 1
                }
			    UnitDamageTarget(DamageTable)
				UtilStun:UnitStunTarget(caster,v,keys.Stun_Duration)
				Timer.Loop 'ability_reimu04_damage' (0.4, keys.Damage_Count-1,
			    function(i)
		            local DamageTable = {
	                    victim = v, 
	                    attacker = caster, 
	                    damage = keys.ability:GetAbilityDamage()/keys.Damage_Count, 
	                    damage_type = keys.ability:GetAbilityDamageType(), 
	                    damage_flags = 1
                    }
			        UnitDamageTarget(DamageTable)
				    UtilStun:UnitStunTarget(caster,v,keys.Stun_Duration)
					local count = v:GetContext("Reimu04_Effect_Damage_Count")
					count = count - 1
					if (count<=0) then
						v:SetContextNum("Reimu04_Effect_Damage_Count" , 0, 0)
						return nil
					else
					    if(v~=nil)then
							v:SetContextNum("Reimu04_Effect_Damage_Count" , count, 0)
						end
					end
			    end
		        )
			end
		end
	end
end