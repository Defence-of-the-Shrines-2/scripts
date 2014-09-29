DonationGem_TriggerTime={}
for i=0,32 do
	DonationGem_TriggerTime[i]=0.0
end

function ItemAbility_ModifierTarget_NotTower(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (ItemAbility:IsItem()) then
		if (Target:IsTower()==false) then
			ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{})
		end
	end
end
function ItemAbility_MrYang_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	
	for i=0.0,keys.SlowdownDuration,keys.SlowdownInterval do
		ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{duration=i})
	end
end

function ItemAbility_SetModifierStackCount(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	
	if (keys.ModifierCount>0) then
		if (Target:HasModifier(keys.ModifierName)==false) then
			ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{})
		end
		Target:SetModifierStackCount(keys.ModifierName,ItemAbility,keys.ModifierCount)
	elseif(Target:HasModifier(keys.ModifierName)) then
		Target:RemoveModifierByName(keys.ModifierName)
	end
end

function ItemAbility_ModifyModifierStackCount(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local ModifierStackCount = 0
	if (Target:HasModifier(keys.ModifierName)) then
		ModifierStackCount=Target:GetModifierStackCount(keys.ModifierName,Caster)
	end
	keys.ModifierCount=ModifierStackCount+keys.CountChange
	ItemAbility_SetModifierStackCount(keys)
end

function ItemAbility_SmashStick_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Target:IsTower()==false) then
		g_UnitStunTarget(Caster,Target,keys.StunDuration)
	end
end

function ItemAbility_GhostBallon_OnAttacked(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker	
	if (Attacker:IsTower()==false) then
		ItemAbility:ApplyDataDrivenModifier(Caster,Attacker,keys.ModifierName,{})
	end
end

function ItemAbility_WindGun_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Target:IsRealHero()==false and Target:IsTower()==false) then
		local damage_table = {
			victim = Target,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			--damage_flags = 1
		}
		ApplyDamage(damage_table)
	end
end

function ItemAbility_Camera_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Target:IsMechanical()==false and Target:IsTower()==false) then
		local damage_to_deal =Target:GetMaxHealth()*keys.DamageHealthPercent
		local damage_table = {
			victim = Target,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_MAGICAL,
			--damage_flags = 1
		}
		--PrintTable(damage_table)
		print("ItemAbility_Camera_OnAttack| Damage:"..damage_to_deal)
		ApplyDamage(damage_table)
	end
end

function ItemAbility_Verity_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Target:IsMechanical()==false and Target:IsTower()==false) then
		local RemoveMana = Target:GetMaxMana()*keys.PenetrateRemoveManaPercent*0.01
		RemoveMana=min(RemoveMana,Target:GetMana())
		--Target:SetMana(Target:GetMana()-RemoveMana)
		Target:ReduceMana(RemoveMana)
		local damage_to_deal = RemoveMana*keys.PenetrateDamageFactor
		if (damage_to_deal>0) then
			local damage_table = {
				victim = Target,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				--damage_flags = 1
			}
			--PrintTable(damage_table)
			print("ItemAbility_Verity_OnAttack| Damage:"..damage_to_deal)
			ApplyDamage(damage_table)
		end
	end
end

function ItemAbility_Kafziel_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Target:IsMechanical()==false and Target:IsTower()==false) then
		local damage_to_deal = (Caster:GetHealth()-Target:GetHealth())*keys.HarvestDamageFactor
		if (damage_to_deal>0) then
			local damage_table = {
				victim = Target,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
				--damage_flags = 1
			}
			--PrintTable(damage_table)
			print("ItemAbility_Kafziel_OnAttack| Damage:"..damage_to_deal)
			ApplyDamage(damage_table)
		end
	end
end

function ItemAbility_Frock_Poison(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker
	if (Attacker:IsMechanical()==false and Attacker:IsTower()==false) then
		local damage_to_deal = 0
		if (Attacker:IsHero()) then
			local MaxAttribute = max(max(Attacker:GetStrength(),Attacker:GetAgility()),Attacker:GetIntellect())
			damage_to_deal = keys.PoisonDamageBase + MaxAttribute*keys.PoisonDamageFactor
		end
		damage_to_deal = max(damage_to_deal,keys.PoisonMinDamage)
		if (damage_to_deal>0) then
			local damage_table = {
				victim = Attacker,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
				--damage_flags = 1
			}
			--PrintTable(damage_table)
			print("ItemAbility_Frock_Poison| Damage:"..damage_to_deal)
			ApplyDamage(damage_table)
		end
	end
end

function ItemAbility_LoneLiness_RegenHealth(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Health = Caster:GetHealth()
	local MaxHealth = Caster:GetMaxHealth()
	local HealthRegen = Caster:GetHealthRegen()
	local HealAmount = (MaxHealth-Health)*keys.PercentHealthRegenBonus*0.01 + HealthRegen*keys.HealthRegenMultiplier*0.01
	Caster:Heal(HealAmount,Caster)
end

function ItemAbility_DoctorDoll_DeclineHealth(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Health = Caster:GetHealth()
	
	local damage_to_deal = min(keys.DeclineHealthPerSec,Health-1)
	if (damage_to_deal>0) then
		local damage_table = {
			victim = Caster,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_PURE,
			--damage_flags = 1
		}
		--PrintTable(damage_table)
		ApplyDamage(damage_table)
	end
end

function ItemAbility_DummyDoll_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	Caster:MakeIllusion()
end

function ItemAbility_Lunchbox_Charge(keys)
	PrintTable(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (ItemAbility:IsItem()) then
		local Charge = ItemAbility:GetCurrentCharges()
		if (Charge<keys.MaxCharges) then
			ItemAbility:SetCurrentCharges(Charge+1)
		end
	end
end

function ItemAbility_Lunchbox_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	if (ItemAbility:IsItem()) then
		local Charge = ItemAbility:GetCurrentCharges()
		local HealAmount = Charge*keys.RestorePerCharge
		if (Charge>0) then
			Caster:Heal(HealAmount,Caster)
			Caster:GiveMana(HealAmount)
			ItemAbility:SetCurrentCharges(0)
		end
	end
end

function ItemAbility_mushroom_kebab_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	Caster:SetBaseStrength(Caster:GetBaseStrength() + keys.IncreaseStrength)
	if (ItemAbility:IsItem()) then
		Caster:RemoveItem(ItemAbility)
		--ItemAbility:Kill()
	end
end

function ItemAbility_mushroom_pie_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	Caster:SetBaseAgility(Caster:GetBaseAgility() + keys.IncreaseAgility)
	if (ItemAbility:IsItem()) then
		Caster:RemoveItem(ItemAbility)
		--ItemAbility:Kill()
	end
end

function ItemAbility_mushroom_soup_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	Caster:SetBaseIntellect(Caster:GetBaseIntellect() + keys.IncreaseIntellect)
	if (ItemAbility:IsItem()) then
		Caster:RemoveItem(ItemAbility)
		--ItemAbility:Kill()
	end
end

function ItemAbility_HorseKing_OnOpen_SpentMana(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	if (Caster:GetMaxMana()>keys.NeedSpentMana) then
		if (Caster:GetManaPercent()<keys.SpentManaPercent) then
			ItemAbility:ToggleAbility()
		else
			local SpentMana = Caster:GetMaxMana()*keys.SpentManaPercent*0.01
			Caster:ReduceMana(SpentMana)
		end
	end
end

function ItemAbility_AbsorbMana(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local AbsorbMana = min(Target:GetMana(),keys.AbsorbManaAmount)
	--Target:SetMana(Target:GetMana()-RemoveMana)
	Target:ReduceMana(AbsorbMana)
	Caster:GiveMana(AbsorbMana)
end

function ItemAbility_DonationBox_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	Target:Kill(ItemAbility,Caster)
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + keys.BonusGold,false)
end

function ItemAbility_DonationGem_GiveGold(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker
	local AttackerPlayerID = Attacker:GetPlayerOwnerID()
	local GameTime=GameRules:GetGameTime()
	if (GameTime-DonationGem_TriggerTime[AttackerPlayerID]>=1.0 and Attacker:HasModifier(keys.AttackerModifierName)) then
		DonationGem_TriggerTime[AttackerPlayerID]=GameTime
		PlayerResource:SetGold(AttackerPlayerID,PlayerResource:GetUnreliableGold(AttackerPlayerID) + keys.BonusGold,false)
	end
end

function ItemAbility_9ball_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local vecCaster = Caster:GetOrigin()
	local radian = RandomFloat(0,6.28)
	local range = RandomFloat(keys.BlinkRangeMin,keys.BlinkRangeMax)
	vecCaster.x = vecCaster.x+math.cos(radian)*range
	vecCaster.y = vecCaster.y+math.sin(radian)*range
	Caster:SetOrigin(vecCaster)
end

function ItemAbility_PresentBox_OnInterval(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	--print("now:"..PlayerResource:GetUnreliableGold(CasterPlayerID).."+"..keys.GiveGoldAmount)
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + keys.GiveGoldAmount,false)
end

function ItemAbility_Peach_OnTakeDamage(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local TakeDamageCount = Caster:GetContext("ItemAbility_Peach_TakeDamageCount")
	local SpeedupDuration = keys.SpeedupDuration
	
	if (TakeDamageCount==nil) then
		TakeDamageCount = keys.Damage
	else
		TakeDamageCount = TakeDamageCount + keys.Damage
	end
	Caster:SetContextNum("ItemAbility_Peach_TakeDamageCount",TakeDamageCount,keys.SpeedupDuration)
	
	if (TakeDamageCount>keys.TakeDamageTrigger) then
		local ModifierCount = round(TakeDamageCount/keys.TakeDamageTrigger)+keys.SpeedupExtraModifierStackCount
		ModifierCount = min(ModifierCount,keys.SpeedupMaxModifierStackCount)
		
		if (Caster:HasModifier(keys.SpeedupModifierName) == false) then
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.SpeedupModifierName,{duration = SpeedupDuration})
		end
		Caster:SetModifierStackCount(keys.SpeedupModifierName,ItemAbility,ModifierCount)
	end
end

function ItemAbility_Yuri_OnSpell(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local ContractOverRange = keys.ContractOverRange
	local ContractionFactor = keys.ContractionFactor
	local BuffModifierName = keys.BuffModifierName
	Caster:SetThink(function ()
		if (Caster:HasModifier(BuffModifierName)==false or Target:IsAlive()==false) then
			return nil
		end
		local CasterPos = Caster:GetOrigin()
		local TargetPos = Target:GetOrigin()
		local Distance = distance(CasterPos,TargetPos)
		if (Distance>ContractOverRange) then
			local vec = TargetPos - CasterPos
			local MoveDistance = (Distance-ContractOverRange)*ContractionFactor
			Caster:SetOrigin(CasterPos + vec:Normalized()*MoveDistance)
		end
		return 0.02
	end)
end

function ItemAbility_ItemSpent(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	
	if (ItemAbility:IsItem()) then
		local Charge = ItemAbility:GetCurrentCharges()
		if (Charge>1) then
			ItemAbility:SetCurrentCharges(Charge-1)
		else
			Caster:RemoveItem(ItemAbility)
		end
	end
end


function round (num)
	return math.floor(num + 0.5)
end
 
function distance(a, b)
    local xx = (a.x-b.x)
    local yy = (a.y-b.y)
    return math.sqrt(xx*xx + yy*yy)
end

function GetAngleBetweenTwoVec(a,b)
	local y = b.y - a.y
	local x = b.x - a.x
	return math.atan2(y,x)
end

function PrintKeys(keys)
	PrintTable(keys)
end

function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..":")
                PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end

function g_UnitStunTarget(caster,target,stuntime)
    UtilStun:UnitStunTarget(caster,target,stuntime)
end