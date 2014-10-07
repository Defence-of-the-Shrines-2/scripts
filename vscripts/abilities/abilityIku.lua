
--羽衣若空 开启
function OnIku01Toggle( keys )
	local caster = keys.caster

	EmitSoundOn("Ability.static.loop", caster)
	
	--标记施法者开始技能
	caster:SetContextNum("Iku01", 1, 0)

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnIku01Toggle"), 
		function( )
			--获取技能等级
			local i = keys.ability:GetLevel() - 1

			--获取技能魔法值
			local mana = keys.ability:GetManaCost(i)

			if caster:GetContext("Iku01")==1 and caster:IsAlive() then

				--当施法者魔法值大于技能要求魔法值
				if caster:GetMana()>mana then
					caster:SetMana(caster:GetMana() - mana)

					if caster:HasModifier("modifier_ability_thdots_iku01")==nil then
						--获取电击伤害
						local light = keys.ability:GetLevelSpecialValueFor("light_damage", i)

						--标记电击伤害
						caster:SetContextNum("Iku01_light", light, 0)

						--添加modifier
						keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_iku01", nil)
						
						EmitSoundOn("Ability.static.loop", caster)
					end
				else
					--施法者魔法书不够，标记电击伤害为0
					caster:SetContextNum("Iku01_light", 0, 0)

					--施法者魔法书不够，删除modifier
					caster:RemoveModifierByName("modifier_ability_thdots_iku01")

					StopSoundEvent("Ability.static.loop", caster)
				end

				return 1
			end

			StopSoundEvent("Ability.static.loop", caster)
			return nil
		end, 1)
end

--羽衣若空 关闭
function OffIku01Toggle( keys )
	local caster = keys.caster

	--标记施法者关闭技能
	caster:SetContextNum("Iku01", 0, 0)

	--标记电击伤害
	caster:SetContextNum("Iku01_light", 0, 0)
end

--雷云棘鱼 击退
function OnIku02Knockback( unit,caster_face,unit_abs,distance,speed )
	local len = 0
	EmitSoundOn("Hero_Zuus.ArcLightning.Cast", unit)
	
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnIku02Knockback"), 
		function( )
			len = len + speed
			if len<distance then
				local vec = caster_face * len
				unit:SetAbsOrigin(unit_abs + vec)

				return 0.01
			end
			unit:AddNewModifier(nil, nil, "modifier_phased", {duration=0.1})
			return nil
		end, 0)
end

--雷云棘鱼
function OnIku02SpellStart( keys )
	local caster = EntIndexToHScript(keys.caster_entindex)
	local group = keys.target_entities
	local caster_abs = caster:GetAbsOrigin()

	--获取技能等级
	local i = keys.ability:GetLevel() - 1

	--获取电击伤害
	local Iku01_light = caster:GetContext("Iku01_light")
	if Iku01_light==nil then
		Iku01_light=0
	end

	--获取闪电伤害
	local light_damage = keys.ability:GetLevelSpecialValueFor("light_damage", i) + Iku01_light

	--获取击退距离
	local distance = keys.ability:GetLevelSpecialValueFor("distance", i)

	for i,unit in pairs(group) do
		local damageTable = {victim=unit,
							attacker=caster,
							damage_type=keys.ability:GetAbilityDamageType(),
							damage=light_damage}
		ApplyDamage(damageTable)

		local unit_abs = unit:GetAbsOrigin()
		OnIku02Knockback(unit,(unit_abs - caster_abs):Normalized(),unit_abs,distance,25)
	end

end

--光龙的吐息 效果
function OnIku03AttackLight( keys,caster,unit,lastUnit,caster_abs,time )
	--获取技能等级
	local i = keys.ability:GetLevel() - 1

	--获取电击伤害
	local Iku01_light = caster:GetContext("Iku01_light")
	if Iku01_light==nil then
		Iku01_light=0
	end

	--获取闪电伤害
	local light_damage = keys.ability:GetLevelSpecialValueFor("light_damage", i) + Iku01_light

	--获取牵引距离
	local distance = keys.ability:GetLevelSpecialValueFor("distance", i)

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnIku03AttackLight"), 
		function( )
			--创建特效
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf",PATTACH_CUSTOMORIGIN_FOLLOW,lastUnit)
			ParticleManager:SetParticleControl(particle,0,lastUnit:GetAbsOrigin() + lastUnit:GetUpVector()*150)
			ParticleManager:SetParticleControl(particle,1,unit:GetAbsOrigin() + unit:GetUpVector()*150)
			ParticleManager:ReleaseParticleIndex(particle)

			--造成伤害
			local damageTable = {victim=unit,
								attacker=caster,
								damage_type=keys.ability:GetAbilityDamageType(),
								damage=light_damage}
			ApplyDamage(damageTable)

			local unit_abs = unit:GetAbsOrigin()
			OnIku02Knockback(unit,(caster_abs - unit_abs):Normalized(),unit_abs,distance,25)

		end, time)	
end

--光龙的吐息
function OnIku03Attack( keys )
	local caster = keys.caster
	local target = keys.target
	local lastUnit = caster
	local lastTarget = target
	local caster_abs = caster:GetAbsOrigin()

	--获取技能等级
	local i = keys.ability:GetLevel() - 1

	--获取电击伤害
	local Iku01_light = caster:GetContext("Iku01_light")
	if Iku01_light==nil then
		Iku01_light=0
	end

	--获取闪电伤害
	local light_damage = keys.ability:GetLevelSpecialValueFor("light_damage", i) + Iku01_light

	--获取牵引距离
	local distance = keys.ability:GetLevelSpecialValueFor("distance", i)

	--获取作用范围
	local radius = keys.ability:GetLevelSpecialValueFor("radius", i)

	--获取传递数量
	local num = keys.ability:GetLevelSpecialValueFor("num", i) + 1

	local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
    local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
    local flags = DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES

    --用于记录单位已经受到了闪电伤害
	local outTarget = {}

	--用于查找单位是否在outTarget
	function outTarget:find(t)
		for i,u in pairs(outTarget) do
			if u==t then
				return false
			end
		end
		return true
	end

	local time = 0
				
	for k=1,num do
		local group = FindUnitsInRadius(caster:GetTeamNumber(), lastTarget:GetOrigin(), nil, radius, teams, types, flags, FIND_CLOSEST, true)
				
		local unit =nil

		--检索单位是否已受到过闪电伤害
		for d,u in pairs(group) do
			lastTarget = u
			unit = u
			if outTarget:find(u) then
				break
			end
		end

		if outTarget:find(lastTarget) and unit then
			table.insert(outTarget,lastTarget)
			
			OnIku03AttackLight( keys,caster,unit,lastUnit,caster_abs,time )

			--设置最后一个单位为命中的单位
			lastUnit=unit

			time = time + 0.15
		else
			break
		end
	end
end

--冲破天际的钻头
function OnIku04SpellStart( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local caster_abs = caster:GetAbsOrigin()
	local caster_face = (point - caster_abs):Normalized()

	--获取技能等级
	local i = keys.ability:GetLevel() - 1

	--获取半径
	local radius = keys.ability:GetLevelSpecialValueFor("radius", i)

	--获取持续时间
	local duration = keys.ability:GetLevelSpecialValueFor("duration", i)

	--获取闪电伤害
	local light_damage = keys.ability:GetLevelSpecialValueFor("damage", i)

	--设置特效创建点
	local vec = caster_abs + radius*caster_face

	--创建特效
	local particle = ParticleManager:CreateParticle("particles/econ/courier/courier_greevil_white/courier_greevil_white_ambient_3.vpcf",PATTACH_CUSTOMORIGIN,caster)
	ParticleManager:SetParticleControl(particle,0,vec)
	ParticleManager:SetParticleControl(particle,1,vec)
	ParticleManager:SetParticleControl(particle,2,Vector(255,255,255))
	ParticleManager:SetParticleControl(particle,3,vec)
	ParticleManager:SetParticleControl(particle,4,caster_face)

	local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
    local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
    local flags = DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES

    --设置电钻角度
    local caster_angle = VectorToAngles(-caster_face)
    local caster_angle_max = caster_angle.y + 15
    local caster_angle_min = caster_angle.y - 15

	local group = FindUnitsInRadius(caster:GetTeamNumber(), vec, nil, radius, teams, types, flags, FIND_CLOSEST, true)

	for k,unit in pairs(group) do
		local unit_abs = unit:GetAbsOrigin()
		local face = (unit_abs - vec):Normalized()
		local angle = VectorToAngles(face)

		local length = (unit_abs - vec):Length()

		if angle.y<caster_angle_max and angle.y>caster_angle_min and length<=radius then
			keys.ability:ApplyDataDrivenModifier(caster, unit, "modifier_ability_thdots_iku04", nil)

			--造成伤害
			local damageTable = {victim=unit,
								attacker=caster,
								damage_type=keys.ability:GetAbilityDamageType(),
								damage=light_damage}
			ApplyDamage(damageTable)
		end
	end
end

function OnIku04Attack( keys )
	local caster = keys.caster
	local target = keys.target

	local ability = caster:FindAbilityByName("ability_thdots_iku03")

	if ability:GetLevel() >= 1 then
		local table = {caster=caster,
						target=target,
						ability=ability}	
		OnIku03Attack(table)
	end
end