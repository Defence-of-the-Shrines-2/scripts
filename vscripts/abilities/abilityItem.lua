DonationGem_TriggerTime={}
for i=0,32 do
	DonationGem_TriggerTime[i]=0.0
end

function ItemAbility_Camera_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local damage_to_deal =Target:GetMaxHealth()*keys.DamageHealthPercent
	local damage_table = {
		victim = Target,
		attacker = Caster,
		damage = damage_to_deal,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 1
	}
	--PrintTable(damage_table)
	print("ItemAbility_Camera_OnAttack| Damage:"..damage_to_deal)
	ApplyDamage(damage_table)
end

function ItemAbility_Verity_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local RemoveMana = Target:GetMaxMana()*keys.PenetrateRemoveManaPercent*0.01
	RemoveMana=min(RemoveMana,Target:GetMana())
	--Target:SetMana(Target:GetMana()-RemoveMana)
	Target:GiveMana(-1*RemoveMana)
	local damage_to_deal = RemoveMana*keys.PenetrateDamageFactor
	if (damage_to_deal>0) then
		local damage_table = {
			victim = Target,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags = 1
		}
		--PrintTable(damage_table)
		print("ItemAbility_Verity_OnAttack| Damage:"..damage_to_deal)
		ApplyDamage(damage_table)
	end
end

function ItemAbility_Kafziel_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local damage_to_deal = (Caster:GetHealth()-Target:GetHealth())*keys.HarvestDamageFactor
	if (damage_to_deal>0) then
		local damage_table = {
			victim = Target,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = 1
		}
		--PrintTable(damage_table)
		print("ItemAbility_Kafziel_OnAttack| Damage:"..damage_to_deal)
		ApplyDamage(damage_table)
	end
end

function ItemAbility_Frock_Poison(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.attacker
	local MaxAttribute = max(max(Caster:GetStrength(),Caster:GetAgility()),Caster:GetIntellect())
	
	local damage_to_deal = keys.PoisonDamageBase + MaxAttribute*keys.PoisonDamageFactor
	damage_to_deal = max(damage_to_deal,keys.PoisonMinDamage)
	if (damage_to_deal>0) then
		local damage_table = {
			victim = Target,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = 1
		}
		--PrintTable(damage_table)
		print("ItemAbility_Frock_Poison| Damage:"..damage_to_deal)
		ApplyDamage(damage_table)
	end
end

function ItemAbility_DoctorDoll_DeclineHealth(keys)
	PrintTable(keys)
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
			damage_flags = 1
		}
		--PrintTable(damage_table)
		print("ItemAbility_Frock_Poison| Damage:"..damage_to_deal)
		ApplyDamage(damage_table)
	end
end

function ItemAbility_Lunchbox_Charge(keys)
	PrintTable(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.Target
	if (ItemAbility:IsItem()) then
		local Charge = ItemAbility:GetCurrentCharges()
		if (Charge<keys.MaxCharges) then
			ItemAbility:SetCurrentCharges(Charge+1)
		end
	end
end

function ItemAbility_Lunchbox_OnSpellStart(keys)
	PrintTable(keys)
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

function ItemAbility_AbsorbMana(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local AbsorbMana = min(Target:GetMana(),keys.AbsorbManaAmount)
	--Target:SetMana(Target:GetMana()-RemoveMana)
	Target:GiveMana(-1*AbsorbMana)
	Caster:GiveMana(AbsorbMana)
end

function ItemAbility_DonationBox_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	Target:Kill(ItemAbility,Caster)
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetGold(CasterPlayerID) + keys.BonusGold,false)
end

function ItemAbility_DonationGem_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	local GameTime=GameRules:GetGameTime()
	if ( Target:IsAlive()==false and GameTime-DonationGem_TriggerTime[CasterPlayerID]>=1.0) then
		DonationGem_TriggerTime[CasterPlayerID]=GameTime
		PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetGold(CasterPlayerID) + keys.BonusGold,false)
	end
end

function ItemAbility_9ball_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local vecCaster = Caster:GetOrigin()
	local radian = RandomFloat(0,6.28)
	local range = RandomFloat(keys.BlinkRangeMin,keys.BlinkRangeMax)
	Caster:SetOrigin(vecCaster.x+math.cos(radian)*range,vecCaster.y+math.sin(radian)*range,vecCaster.z)
end

function ItemAbility_GiveGold(keys)
	local ItemAbility = keys.ability
	local Targer = keys.Targer
	local TargerPlayerID = Targer:GetPlayerOwnerID()
	PlayerResource:SetGold(TargerPlayerID,PlayerResource:GetGold(TargerPlayerID) + keys.GiveGoldAmount,false)
end

function ItemAbility_SetModifierStackCount(keys)
	PrintKeys(keys)
	local ItemAbility = keys.ability
	local Targer = keys.Targer
	
	if (keys.ModifierCount>0) then
		if (Target:HasModifier(keys.ModifierName)) then
			Target:SetModifierStackCount(keys.ModifierName,ItemAbility,keys.ModifierCount)
		end
	elseif(Target:HasModifier(keys.ModifierName)) then
		Target:RemoveModifierByName(keys.ModifierName)
	end
end

function ItemAbility_ModifyModifierStackCount(keys)
	local ItemAbility = keys.ability
	local Targer = keys.Targer
	local ModifierStackCount = 0
	if (Target:HasModifier(keys.ModifierName)) then
		ModifierStackCount=Target:GetModifierStackCount(keys.ModifierName,ItemAbility)
	end
	keys.ModifierCount=ModifierStackCount+keys.CountChange
	ItemAbility_SetModifierStackCount(keys)
end

function PrintKeys(keys)
	PrintTable(keys)
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