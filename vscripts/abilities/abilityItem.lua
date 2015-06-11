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
	local damage_to_deal = keys.PhysicalDamage
	if (Target:IsRealHero()==false and Target:IsTower()==false) then
		local damage_table = {
			ability = ItemAbility,
			victim = Target,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags = 1
		}
		ApplyDamage(damage_table)
		local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_wind_gun.vpcf", PATTACH_ABSORIGIN_FOLLOW, Target)
		ParticleManager:SetParticleControl(effectIndex, 0, Target:GetAbsOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, Caster:GetAbsOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)
	end
end

function ItemAbility_Camera_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Target:IsMechanical()==false and Target:IsTower()==false) then
		local damage_to_deal =Target:GetMaxHealth()*keys.DamageHealthPercent
		local damage_table = {
			ability = ItemAbility,
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
end

function ItemAbility_Verity_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Target:IsMechanical()==false and Target:IsTower()==false) then
		local RemoveMana = Target:GetMaxMana()*keys.PenetrateRemoveManaPercent*0.01
		RemoveMana=min(RemoveMana,Target:GetMana())
		Target:ReduceMana(RemoveMana)
		local damage_to_deal = RemoveMana*keys.PenetrateDamageFactor
		if (damage_to_deal>0) then
			local damage_table = {
				ability = ItemAbility,
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
end

function ItemAbility_Kafziel_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Target:IsMechanical()==false and Target:IsTower()==false) then
		local damage_to_deal = (Caster:GetHealth()-Target:GetHealth())*keys.HarvestDamageFactor
		if (damage_to_deal>0) then
			local damage_table = {
				ability = ItemAbility,
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
				ability = ItemAbility,
				victim = Attacker,
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
			damage_flags = 1
		}
		--PrintTable(damage_table)
		ApplyDamage(damage_table)
	end
end

function ItemAbility_DummyDoll_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	
	ProjectileManager:ProjectileDodge(Caster)
	--create_illusion(keys, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	illusion=create_illusion(keys,Caster:GetAbsOrigin(),keys.illusion_damage_percent_incoming_melee,0,keys.illusions_duration)
	if (illusion ~= nil) then
		local CasterAngles = Caster:GetAnglesAsVector()
		illusion:SetAngles(CasterAngles.x,CasterAngles.y,CasterAngles.z)
		--illusion:SetForwardVector(Caster:GetForwardVector())
	end
end

function ItemAbility_Lunchbox_Charge(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local CurrentActiveAbility= Caster:GetCurrentActiveAbility()
	if (ItemAbility:IsItem() and CurrentActiveAbility:IsItem()==false) then
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

function ItemAbility_God_Lunchbox_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	if (ItemAbility:GetCurrentCharges()==keys.MaxCharges) then
		--Purge(bool RemovePositiveBuffs, bool RemoveDebuffs, bool BuffsCreatedThisFrameOnly, bool RemoveStuns, bool RemoveExceptions) 
		Caster:Purge(false,true,false,true,false)
	end
	ItemAbility_Lunchbox_OnSpellStart(keys) --Spent Charges
end

function ItemAbility_DragonStar_Purge(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	print("ItemAbility_Dragon_Star_Purge")
	--Purge(bool RemovePositiveBuffs, bool RemoveDebuffs, bool BuffsCreatedThisFrameOnly, bool RemoveStuns, bool RemoveExceptions) 
	Caster:Purge(false,true,false,true,false)
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
		if (Caster:GetManaPercent()<keys.SpentManaPercent and ItemAbility:GetToggleState()) then
			ItemAbility:ToggleAbility()
		else
			local SpentMana = Caster:GetMaxMana()*keys.SpentManaPercent*0.01
			Caster:ReduceMana(SpentMana)
		end
	end
end

function ItemAbility_HorseKing_ToggleOff(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	if (ItemAbility:GetToggleState()) then
		ItemAbility:ToggleAbility()
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
	local GoldBounty = Target:GetGoldBounty()
	Target:SetMaximumGoldBounty(GoldBounty+keys.BonusGold)
	Target:SetMinimumGoldBounty(GoldBounty+keys.BonusGold)
	Target:Kill(ItemAbility,Caster)
	
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, Caster)
	ParticleManager:SetParticleControl(effectIndex, 0, Caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, Target:GetAbsOrigin())
	
	local Duration=0.0
	Caster:SetThink(function ()
		if (Duration>1.0) then 
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			return nil 
		end
		
		Duration = Duration+0.02
		ParticleManager:SetParticleControl(effectIndex, 0, Caster:GetAbsOrigin())
		return 0.02
	end)
end

function ItemAbility_DonationGem_AddTargetGoldBounty(keys)
	local ItemAbility = keys.ability
	local Target = keys.target
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	local GoldBounty = Target:GetGoldBounty()
	Target:SetMaximumGoldBounty(GoldBounty+keys.GoldBounty)
	Target:SetMinimumGoldBounty(GoldBounty+keys.GoldBounty)
	if (GameRules:GetGameTime()-DonationGem_TriggerTime[CasterPlayerID]<1.0) then
		Target:RemoveModifierByName(keys.ModifierName)
	end
end

function ItemAbility_DonationGem_ReduceTargetGoldBounty(keys)
	local ItemAbility = keys.ability
	local Target = keys.target
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	local GoldBounty = Target:GetGoldBounty()
	Target:SetMaximumGoldBounty(GoldBounty-keys.GoldBounty)
	Target:SetMinimumGoldBounty(GoldBounty-keys.GoldBounty)
end

function ItemAbility_DonationGem_UpdateTiggerTime(keys)
	local ItemAbility = keys.ability
	local Target = keys.target
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	DonationGem_TriggerTime[CasterPlayerID]=GameRules:GetGameTime()
	
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_gem.vpcf", PATTACH_ABSORIGIN_FOLLOW, Caster)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
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
	SetTargetToTraversable(Caster)
end

function ItemAbility_PresentBox_RestoreGold(keys)
	local ItemAbility = keys.ability
	if (ItemAbility:IsItem())then
		local Caster = keys.caster
		local CasterPlayerID = Caster:GetPlayerOwnerID()
		local RestoreGold = ItemAbility:GetCost()*keys.RestoreGoldPercent*0.01
		PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + RestoreGold,false)
		Caster:RemoveItem(ItemAbility)
	end
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
	local DamageTaken = keys.DamageTaken
	local TakeDamageCount = Caster.ItemAbility_Peach_TakeDamageCount
	local SpeedupDuration = keys.SpeedupDuration
	local SpeedupModifierName = keys.SpeedupModifierName
	local SpeedupMaxModifierStack = keys.SpeedupMaxModifierStack
	local TimeNow = GameRules:GetGameTime()
	if (TakeDamageCount==nil) then
		TakeDamageCount=0
	end
	
	if (Caster.ItemAbility_Peach_LastTriggerTime==nil or TimeNow-Caster.ItemAbility_Peach_LastTriggerTime>=SpeedupDuration) then
		TakeDamageCount=0
		Caster.ItemAbility_Peach_LastTriggerTime = GameRules:GetGameTime()
	end
	
	TakeDamageCount = TakeDamageCount + DamageTaken
	Caster.ItemAbility_Peach_TakeDamageCount=TakeDamageCount
	print("Item_Peach TakenDamageCount.."..TakeDamageCount)
	
	if (TakeDamageCount>keys.TakeDamageTrigger) then
		local ModifierCount = round(TakeDamageCount/keys.TakeDamageTrigger)+1
		local TriggerBuff = nil
		ModifierCount = min(ModifierCount,SpeedupMaxModifierStack)
		
		if (Caster:HasModifier(SpeedupModifierName)) then
			if (Caster:GetModifierStackCount(SpeedupModifierName,Caster)~=ModifierCount or (ModifierCount==SpeedupMaxModifierStack and TimeNow>Caster.ItemAbility_Peach_LastTriggerTime)) then
				Caster:RemoveModifierByName(SpeedupModifierName)
				ItemAbility:ApplyDataDrivenModifier(Caster,Caster,SpeedupModifierName,{duration = SpeedupDuration})
				Caster:SetModifierStackCount(SpeedupModifierName,ItemAbility,ModifierCount)
				TriggerBuff = true
			end
		else
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,SpeedupModifierName,{duration = SpeedupDuration})
			Caster:SetModifierStackCount(SpeedupModifierName,ItemAbility,ModifierCount)
			TriggerBuff = true
		end
		
		if (TriggerBuff) then
			Caster.ItemAbility_Peach_LastTriggerTime = TimeNow
		end
	end
end

function ItemAbility_Anchor_OnTakeDamage(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local DamageTaken = keys.DamageTaken
	local TakeDamageCount = Caster.ItemAbility_Anchor_TakeDamageCount
	local BuffDuration = keys.BuffDuration
	local IconModifierName = keys.IconModifierName
	local BuffMaxStack = keys.BuffMaxStack
	local TimeNow = GameRules:GetGameTime()
	if (TakeDamageCount==nil) then
		TakeDamageCount=0
	end
	
	if (Caster.ItemAbility_Anchor_LastTriggerTime==nil or TimeNow-Caster.ItemAbility_Anchor_LastTriggerTime>=BuffDuration) then
		TakeDamageCount=0
		Caster.ItemAbility_Anchor_LastTriggerTime = TimeNow
	end
	
	TakeDamageCount = TakeDamageCount + DamageTaken
	Caster.ItemAbility_Anchor_TakeDamageCount=TakeDamageCount
	print("Item_Anchor TakenDamageCount.."..TakeDamageCount)
	
	if (TakeDamageCount>keys.TakeDamageTrigger) then
		local ModifierCount = round(TakeDamageCount/keys.TakeDamageTrigger)+1
		local TriggerBuff = nil
		ModifierCount = min(ModifierCount,BuffMaxStack)
		
		if (Caster:HasModifier(IconModifierName)) then
			if (Caster:GetModifierStackCount(IconModifierName,Caster)~=ModifierCount or (ModifierCount==BuffMaxStack and TimeNow>Caster.ItemAbility_Anchor_LastTriggerTime)) then
				Caster:RemoveModifierByName(IconModifierName)
				ItemAbility:ApplyDataDrivenModifier(Caster,Caster,IconModifierName,{duration = BuffDuration})
				Caster:SetModifierStackCount(IconModifierName,ItemAbility,ModifierCount)
				TriggerBuff = true
			end
		else
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,IconModifierName,{duration = BuffDuration})
			Caster:SetModifierStackCount(keys.IconModifierName,ItemAbility,ModifierCount)
			TriggerBuff = true
		end
		
		if (TriggerBuff) then
			Caster.ItemAbility_Anchor_LastTriggerTime = TimeNow
		end
	end
end

function ItemAbility_Anchor_OnAttackStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local CritChance = keys.CritChanceConst
	
	if (Caster:HasModifier(keys.IconModifierName)) then
		CritChance = CritChance + Caster:GetModifierStackCount(keys.IconModifierName,Caster)*keys.BuffCritChance
	end
	
	if (CritChance>=RandomInt(1,100)) then
		ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.CritModifierName,{})
	end
end

function ItemAbility_Yuri_OnSpell(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local ContractOverRange = keys.ContractOverRange
	local MaxRange = ContractOverRange*3
	local ContractionFactor = keys.ContractionFactor
	local BuffModifierName = keys.BuffModifierName
	local FirstDistance = ContractOverRange --min(ContractOverRange,distance(Caster:GetOrigin(),Target:GetOrigin()))
	local LastDistance = FirstDistance
	--ContractionFactor = (FirstDistance/ContractOverRange)*ContractionFactor
	Caster:SetThink(function ()
		local CasterPos = Caster:GetAbsOrigin()
		local TargetPos = Target:GetAbsOrigin()
		local Distance = distance(CasterPos,TargetPos)
		if (Caster:HasModifier(BuffModifierName)==false or Target:IsAlive()==false or Distance>MaxRange) then
			Caster:RemoveModifierByName(BuffModifierName)
			return nil
		end
		if (Distance>FirstDistance) then -- and Distance>LastDistance) then
			local vec = TargetPos - CasterPos
			local MoveDistance = (Distance-FirstDistance)
			MoveDistance=MoveDistance*MoveDistance*0.001*ContractionFactor
			MoveDistance=max(MoveDistance,0.1)
			Caster:SetAbsOrigin(CasterPos + vec:Normalized()*MoveDistance)
		end
		LastDistance = Distance
		return 0.02
	end)
end

function ItemAbility_Physical_Block(keys)
	local Caster = keys.caster
	local DamageBlock = min(keys.DamageBlock,keys.DamageTaken)
	--print("DamageBlock"..DamageBlock)
	Caster:SetHealth(Caster:GetHealth()+DamageBlock)
end

function ItemAbility_Moon_Bow_OnHit(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local damage_to_deal = keys.arrow_damage_const + Caster:GetIntellect()*keys.arrow_damage_int_mult
	--if (Target:IsHero()) then
		if (damage_to_deal>0) then
			local damage_table = {
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage_flags = 1
			}
			--PrintTable(damage_table)
			print("ItemAbility_Moon_Bow_OnHit| Damage:"..damage_to_deal)
			ApplyDamage(damage_table)
		end
	--end
end
--------------------------------------------------------------------------------------------------------
--[[
	item_hakurei_amulet
]]
function is_spell_blocked_by_hakurei_amulet(target)
	if target:HasModifier("modifier_item_sphere_target") then
		target:RemoveModifierByName("modifier_item_sphere_target")  --The particle effect is played automatically when this modifier is removed (but the sound isn't).
		target:EmitSound("DOTA_Item.LinkensSphere.Activate")
		return true
	end
	return false
end

function ItemAbility_HakureiAmulet_OnCreated(keys)
	if keys.ability ~= nil and keys.ability:IsCooldownReady() then
		if keys.caster:HasModifier("modifier_item_sphere_target") then  --Remove any potentially temporary version of the modifier and replace it with an indefinite one.
			keys.caster:RemoveModifierByName("modifier_item_sphere_target")
		end
		keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_sphere_target", {duration = -1})
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_hakurei_amulet_icon", {duration = -1})
	end
end

function ItemAbility_HakureiAmulet_OnDestroy(keys)
	local num_off_cooldown_linkens_spheres_in_inventory = 0
	for i=0, 5, 1 do --Search for off-cooldown Linken's Spheres in the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_sphere_datadriven" and current_item:IsCooldownReady() then
				num_off_cooldown_linkens_spheres_in_inventory = num_off_cooldown_linkens_spheres_in_inventory + 1
			end
		end
	end
	
	--If the player just got rid of their last Linken's Sphere, which was providing the passive spellblock.
	if num_off_cooldown_linkens_spheres_in_inventory == 0 then
		keys.caster:RemoveModifierByName("modifier_item_sphere_target")
	end
end

function ItemAbility_HakureiAmulet_OnIntervalThink(keys)
	local num_off_cooldown_linkens_spheres_in_inventory = 0
	for i=0, 5, 1 do --Search for off-cooldown Linken's Spheres in the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_hakurei_amulet" and current_item:IsCooldownReady() then
				num_off_cooldown_linkens_spheres_in_inventory = num_off_cooldown_linkens_spheres_in_inventory + 1
			end
		end
	end

	if num_off_cooldown_linkens_spheres_in_inventory > 0 and not keys.caster:HasModifier("modifier_item_sphere_target") then
		keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_sphere_target", {duration = -1})
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_hakurei_amulet_icon", {duration = -1})
		for i=0, 5, 1 do --Put all Linken's Spheres in the player's inventory on cooldown.
			local current_item = keys.caster:GetItemInSlot(i)
			if current_item ~= nil then
				if current_item:GetName() == "item_hakurei_amulet" then
					current_item:StartCooldown(current_item:GetCooldown(current_item:GetLevel()))
				end
			end
		end
		num_off_cooldown_linkens_spheres_in_inventory = 0
	end
end

function ItemAbility_HakureiAmulet_DisplayIcon_OnIntervalThink(keys)
	if not keys.target:HasModifier("modifier_item_sphere_target") then
		keys.target:RemoveModifierByName("modifier_item_hakurei_amulet_icon")
	end
end
--------------------------------------------------------------------------------------------------------
function ItemAbility_Debug_GetGold(keys)
	print("ItemAbility_GetGold"..keys.bonus_gold)
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerID()
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + keys.bonus_gold,false)
end
function ItemAbility_Debug_PrintHealth(keys)
	if (keys.caster) then
		print(keys.debug_string.."caster health is "..keys.caster:GetHealth())
	end
	if (keys.target) then
		print(keys.debug_string.."target health is "..keys.target:GetHealth())
	end
end
-------------------------------------------------------------------------------------------------------------------
--[[Author: Pizzalol
	Date: 18.01.2015.
	Checks if the target is an illusion, if true then it kills it
	otherwise the target model gets swapped into a frog]]
function voodoo_start( keys )
	local target = keys.target
	local model = keys.model

	if target:IsIllusion() then
		target:ForceKill(true)
	else
		if target.target_model == nil then
			target.target_model = target:GetModelName()
		end

		target:SetOriginalModel(model)
	end
end

--[[Author: Pizzalol
	Date: 18.01.2015.
	Reverts the target model back to what it was]]
function voodoo_end( keys )
	local target = keys.target

	-- Checking for errors
	if target.target_model ~= nil then
		target:SetModel(target.target_model)
		target:SetOriginalModel(target.target_model)
	end
end

--[[Author: Noya
	Date: 10.01.2015.
	Hides all dem hats
]]
function HideWearables( event )
	--[[
	local hero = event.target
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	print("Hiding Wearables")
	--hero:AddNoDraw() -- Doesn't work on classname dota_item_wearable

	hero.wearableNames = {} -- In here we'll store the wearable names to revert the change
	hero.hiddenWearables = {} -- Keep every wearable handle in a table, as its way better to iterate than in the MovePeer system
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            if string.find(modelName, "invisiblebox") == nil then
            	-- Add the original model name to revert later
            	table.insert(hero.wearableNames,modelName)
            	print("Hidden "..modelName.."")

            	-- Set model invisible
            	model:SetModel("models/development/invisiblebox.vmdl")
            	table.insert(hero.hiddenWearables,model)
            end
        end
        model = model:NextMovePeer()
        if model ~= nil then
        	print("Next Peer:" .. model:GetModelName())
        end
    end]]
end

--[[Author: Noya
	Date: 10.01.2015.
	Shows the hidden hero wearables
]]
function ShowWearables( event )
	--[[
	local hero = event.target
	print("Showing Wearables on ".. hero:GetModelName())

	-- Iterate on both tables to set each item back to their original modelName
	for i,v in ipairs(hero.hiddenWearables) do
		for index,modelName in ipairs(hero.wearableNames) do
			if i==index then
				print("Changed "..v:GetModelName().. " back to "..modelName)
				v:SetModel(modelName)
			end
		end
	end]]
end
------------------------------------------------------------------------------------------------

function create_illusion(keys, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	local player_id = keys.caster:GetPlayerID()
	local caster_team = keys.caster:GetTeam()
	
	local illusion = CreateUnitByName(keys.caster:GetUnitName(), illusion_origin, true, keys.caster, nil, caster_team)  --handle_UnitOwner needs to be nil, or else it will crash the game.
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)

	--Level up the illusion to the caster's level.
	local caster_level = keys.caster:GetLevel()
	for i = 1, caster_level - 1 do
		illusion:HeroLevelUp(false)
	end

	--Set the illusion's available skill points to 0 and teach it the abilities the caster has.
	illusion:SetAbilityPoints(0)
	for ability_slot = 0, 15 do
		local individual_ability = keys.caster:GetAbilityByIndex(ability_slot)
		if individual_ability ~= nil then 
			local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
			if illusion_ability ~= nil then
				illusion_ability:SetLevel(individual_ability:GetLevel())
			end
		end
	end

	--Recreate the caster's items for the illusion.
	for item_slot = 0, 5 do
		local individual_item = keys.caster:GetItemInSlot(item_slot)
		if individual_item ~= nil then
			local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
			illusion:AddItem(illusion_duplicate_item)
		end
	end
	
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
	illusion:AddNewModifier(keys.caster, keys.ability, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})
	
	illusion:MakeIllusion()  --Without MakeIllusion(), the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.  Without it, IsIllusion() returns false and IsRealHero() returns true.

	return illusion
end

-- extra keys params:
-- string keys.ModifierName
-- int keys.ModifierCount
-- table keys.ApplyModifierParams
function ItemAbility_SetModifierStackCount(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	
	if (keys.ModifierCount>0) then
		if (Target:HasModifier(keys.ModifierName)==false) then
			local Params = {}
			if (keys.ApplyModifierParams) then
				Params=keys.ApplyModifierParams
			end
			ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,Params)
		end
		Target:SetModifierStackCount(keys.ModifierName,ItemAbility,keys.ModifierCount)
	elseif(Target:HasModifier(keys.ModifierName)) then
		Target:RemoveModifierByName(keys.ModifierName)
	end
end

-- extra keys params:
-- int keys.CountChange
-- string keys.ModifierName
-- int keys.ModifierCount
-- table keys.ApplyModifierParams
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

function clamp (Num, Min, Max)
	if (Num>Max) then return Max
	elseif (Num<Min) then return Min
	else return Num
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