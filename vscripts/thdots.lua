print ('[THDOTS] THDOTS Starting..' )

STARTING_GOLD = 500--650
DEBUG = true
GameMode = nil

TRUE = 1
FALSE = 0


if THDOTSGameMode == nil then
	THDOTSGameMode = class({})
end

-- Load Stat collection (statcollection should be available from any script scope)
require('lib.statcollection')
require('lib.loadhelper')

statcollection.addStats({
  modID = '18a7102085aa084ebcb112a1093c9e02' --GET THIS FROM http://getdotastats.com/#d2mods__my_mods
})

-- setmetatable是lua面向对象的编程方法~

-- 这个函数是addon_game_mode里面所写的，会在vlua.cpp执行的时候所执行的内容
function THDOTSGameMode:InitGameMode()
  print('[THDOTS] Starting to load THDots gamemode...')

  InitLogFile( "log/dota2x.txt","")
  -- 初始化记录文件
  -- 这个记录文件的路径是 dota 2 beta/dota/log/dota2x.txt
  -- 在有必要的时候，你可以使用  AppendToLogFile("log/dota2x.txt","记录内容")
  -- 来记录一些数据，避免游戏的崩溃了，却无法看到控制台的报错，无法判断是哪里出了问题

  -- 游戏事件监听
  -- 监听的API规则是
  -- ListenToGameEvent(API定义的事件名称或者我们自己程序发出的事件名称,事件触发之后执行的函数,LUA所有者)
  -- 这里所使用的 Dynamic_Wrap(THDOTSGameMode, 'OnEntityKilled') 其实就相当于self:OnEntityKilled
  -- 使用Dynamic_Wrap的好处是可以在控制台输入 developer 1之后，控制台显示一些额外的信息
  
  ListenToGameEvent('entity_killed', Dynamic_Wrap(THDOTSGameMode, 'OnEntityKilled'), self)
  -- 监听单位被击杀的事件
  
  ListenToGameEvent('player_connect_full', Dynamic_Wrap(THDOTSGameMode, 'AutoAssignPlayer'), self)
  -- 监听玩家连接完成的事件，这里的函数 AutoAssignPlayer 是自动分配玩家英雄

  ListenToGameEvent('player_disconnect', Dynamic_Wrap(THDOTSGameMode, 'CleanupPlayer'), self)
  -- 监听玩家断开连接的事件，有时候当玩家断开连接，我们可能要为其清理英雄，储存相关数据，等他重连之后再重新赋给他

  ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(THDOTSGameMode, 'ShopReplacement'), self)
  -- 监听物品被购买的事件

  ListenToGameEvent('player_say', Dynamic_Wrap(THDOTSGameMode, 'PlayerSay'), self)
  -- 监听玩家聊天事件，这可以用来监听一些指令

  ListenToGameEvent('player_connect', Dynamic_Wrap(THDOTSGameMode, 'PlayerConnect'), self)
  -- 玩家连接事件

  ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(THDOTSGameMode, 'AbilityUsed'), self)

  ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(THDOTSGameMode, 'AbilityLearn'), self)
 
  -- 玩家使用了某个技能事件

  -- 注册控制台命令的参数
  -- 使用注册控制台命令
  -- 可以让我们通过控制台执行一些指令
  -- API规则为
  -- ConVars:RegisterConvar(命令,执行的程序,显示的帮助信息,一般为0)
  --如 Convars:RegisterCommand( "command_example", Dynamic_Wrap(THDOTSGameMode, 'ExampleConsoleCommand'), "A console command example", 0 )
  
  -- 这个函数可以帮我们将整个房间的空位充满测试英雄
  Convars:RegisterCommand('fake', function()
    -- 检查是否由服务器执行，或者DEBUG常亮设置为true
    if not Convars:GetCommandClient() or DEBUG then
      -- 告诉服务器创建虚假客户端
      SendToServerConsole('dota_create_fake_clients')
      -- 创建一个并行Timer来执行虚假客户端的创建
      self:CreateTimer('assign_fakes', {
        -- Timer的执行时间为立即执行
        endTime = Time(),
        -- callback就是指当执行时间达到的时候，索要执行的函数
        callback = function(dota2x, args)
          -- 从1号位玩家开始，循环到10号位
          for i=0, 9 do
            -- 检查这个位置是否是虚假客户端
            if PlayerResource:IsFakeClient(i) then
              -- 获取这个玩家，返回的类型是CDOTAPlayer
              local ply = PlayerResource:GetPlayer(i)
              -- 确认已经获取到这个玩家
              if ply then
                -- 为这个玩家创建一个英雄
                --  CreateHeroForPlayer( 英雄名字, 所有者（必须为CDOTAPlayer类型）)
                CreateHeroForPlayer('npc_dota_hero_axe', ply)
              end
            end
          end
        end}) -- Timer结束
    end
  end, 'Connects and assigns fake Players.', 0) 
  -- 完成控制台命令的注册
  -- 之后在游戏的过程中，就可以通过控制台输入fake，来将其他的空位都填满斧王

  -- 产生随机数种子，主要是为了程序中的随机数考虑
  local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  math.randomseed(tonumber(timeTxt))

  -- 初始化计时器Table
  self.timers = {}

  -- 以下就是一些推荐使用的Table变量
  self.vUserNames = {}
  self.vUserIds = {}
  self.vSteamIds = {}
  self.vBots = {}
  self.vBroadcasters = {}
  self.vPlayers = {}
  self.vRadiant = {}
  self.vDire = {}
  self.vPlayerHeroData = {}

end

-- 这个函数是在有玩家连接到游戏之后，调用的，请查看 THDOTSGameMode:AutoAssignPlayer里面调用这个函数的部分
-- 主要是设置属于游戏模式的相关规则，并且开启循环计时器
function THDOTSGameMode:CaptureGameMode()
  if GameMode == nil then
	GameMode = GameRules:GetGameModeEntity()		

    -- 设定镜头距离的大小，默认为1134
    GameMode:SetCameraDistanceOverride( 1504.0 )

    -- 设定使用自定义的买活话费，买活冷却，设定是否能买活参数
    --GameMode:SetCustomBuybackCostEnabled( true )
    --GameMode:SetCustomBuybackCooldownEnabled( true )
    --GameMode:SetBuybackEnabled( false )
	
    -- 设定GAMEMODE这个实体的循环函数，0.1秒执行一次，其实每一个实体都可以通过SetContextThink来
    -- 设定一个循环函数
    -- 语法为
    -- Entity:SetContextThink(名字，循环函数，循环时间)
    -- 和ListenToGameEvent一样，这里也使用了Dynamic_Wrap
    GameMode:SetContextThink("Dota2xThink", Dynamic_Wrap( THDOTSGameMode, 'Think' ), 0.1 )

    -- Register Think
    --GameMode:SetContextThink( "THDOTSGameMode:GameThink", function() return self:GameThink() end, 0.25 )
  end 
end

function PrecacheHeroResource(hero)
	local heroName = hero:GetClassname()
	local context

	--local abilityCollection = hero:FindAbilityByName("ability_collection_power")
  --abilityCollection:SetLevel(1)
  local abilityEx
	--local PlyID=hero:GetPlayerOwnerID()
	--PlayerResource:SetGold(PlyID,999999,true)
  --[[for i=1,1000 do
    local ent = EntIndexToHScript(i)
    if(ent~=nil)then
        print(tostring(i))
        print(ent:GetName())
    end
  end]]--
	if(heroName == "npc_dota_hero_slark")then
		require( 'abilities/abilityAya' )
		--[[PrecacheResource( "particle", "particles/units/heroes/hero_brewmaster/brewmaster_windwalk_dust.vpcf", context )--文文D
		PrecacheResource( "particle", "particles/units/heroes/hero_windrunner/windrunner_spell_powershot_trail_e.vpcf", context )--文文D
		PrecacheResource( "particle", "particles/units/heroes/hero_beastmaster/beastmaster_wildaxe_glow.vpcf", context )--文文F
		PrecacheResource( "particle", "particles/econ/items/windrunner/windrunner_cape_cascade/windrunner_windrun_cascade.vpcf", context )--文文R
		PrecacheResource( "particle", "particles/units/heroes/hero_windrunner/windrunner_poof.vpcf", context )--文文W]]--
	elseif(heroName == "npc_dota_hero_lina")then
		require( 'abilities/abilityReimu' )
		--[[PrecacheResource( "model", "models/thd2/yyy.vmdl", context )--灵梦D
		PrecacheResource( "particle", "particles/thd2/heroes/reimu/reimu_01_effect_fire.vpcf", context )--灵梦D
		PrecacheResource( "particle", "particles/thd2/heroes/reimu/reimu_01_effect.vpcf", context )--灵梦D
		PrecacheResource( "particle", "particles/dire_fx/tower_bad_face.vpcf", context )--灵梦R
		PrecacheResource( "particle", "particles/thd2/heroes/reimu/reimu_03_effect.vpcf", context )--灵梦R
		PrecacheResource( "particle", "particles/thd2/heroes/reimu/reimu_04_effect.vpcf", context )--灵梦W]]--
	elseif(heroName == "npc_dota_hero_juggernaut")then
		require( 'abilities/abilityYoumu' )
		--[[PrecacheResource( "particle", "particles/thd2/heroes/youmu/youmu_01_blink_effect.vpcf", context )--妖梦D
		PrecacheResource( "model", "models/heroes/juggernaut/juggernaut.vmdl", context )--妖梦R
		PrecacheResource( "particle", "particles/items2_fx/teleport_end_i.vpcf", context )--像妖梦樱花
		PrecacheResource( "particle", "particles/thd2/heroes/youmu/youmu_04_sword_effect.vpcf", context )--妖梦大
		PrecacheResource( "particle", "particles/thd2/heroes/youmu/youmu_04_blossoms_effect.vpcf", context )--妖梦大]]--
	elseif(heroName == "npc_dota_hero_earthshaker")then
		require( 'abilities/abilityTensi' )
		--[[PrecacheResource( "particle", "particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_fallback_low_egset.vpcf", 
	context )--天子F
		PrecacheResource( "particle", "particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", context )--天子大
		PrecacheResource( "particle", "particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start_bolt_parent.vpcf", context )--天子大]]--
	elseif(heroName == "npc_dota_hero_dark_seer")then
		require( 'abilities/abilityByakuren' )
		--[[PrecacheResource( "particle", "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf",context)--白莲D
		PrecacheResource( "particle", "particles/units/heroes/hero_leshrac/leshrac_pulse_nova_h.vpcf",context)--白莲F
		PrecacheResource( "particle", "particles/econ/events/ti4/teleport_start_counter_ti4.vpcf",context)--白莲R]]--
	elseif(heroName == "npc_dota_hero_crystal_maiden")then
		require( 'abilities/abilityMarisa' )
		--[[PrecacheResource( "particle", "particles/thd2/heroes/marisa/marisa_01_rocket.vpcf", context )--魔理沙D
		PrecacheResource( "particle", "particles/thd2/heroes/marisa/marisa_02_stars.vpcf", context )--魔理沙F
		PrecacheResource( "model", "models/props_gameplay/rune_haste01.vmdl", context )--魔理沙R
		PrecacheResource( "model", "models/thd2/masterspark.vmdl", context )--魔理沙 魔炮
		PrecacheResource( "particle", "particles/thd2/heroes/marisa/marisa_04_spark.vpcf", context )--魔理沙 魔炮特效]]--
  elseif(heroName == "npc_dota_hero_necrolyte")then
    require( 'abilities/abilityYuyuko' )
    abilityEx = hero:FindAbilityByName("ability_thdots_yuyukoEx")
    abilityEx:SetLevel(1)
   elseif(heroName == "npc_dota_hero_templar_assassin")then
    require( 'abilities/abilitySakuya' )
    abilityEx = hero:FindAbilityByName("ability_thdots_sakuyaEx")
    abilityEx:SetLevel(1)
  elseif(heroName == "npc_dota_hero_naga_siren")then
    require( 'abilities/abilityFlandre' )
  elseif(heroName == "npc_dota_hero_chaos_knight")then
    require( 'abilities/abilityMokou' )
	end
end
-- 以下的这些函数，大多都是把传递的数值Print出来
-- PrintTable和print的东西，都会显示在控制台上
-- PrintTable会显示例如
-- caster:
--        table:0x00ff000
-- caster_entindex:195
-- target:
--        table:0x00ff000
-- 这样的内容，那么我们就可以通过keys.caster_entindex来获取这个caster的Entity序号
-- 再通过
-- EntIndexToHScript(keys.caster_entindex)
-- 就可以获取这个施法者相对应的hScript了

function THDOTSGameMode:AbilityUsed(keys)
  local ply = EntIndexToHScript(keys.PlayerID)
  local caster = ply:GetAssignedHero()
  local ability = caster:FindAbilityByName(keys.abilityname)
  if(keys.abilityname == 'phoenix_supernova')then
    local mokouAbility1 = caster:FindAbilityByName("ability_thdots_mokou01")
    local mokouAbility = caster:FindAbilityByName("ability_thdots_mokou04")
    if(mokouAbility:GetLevel()>0)then
      local mokouCooldown = mokouAbility:GetCooldownTimeRemaining()-ability:GetLevel()
      if(mokouCooldown>=0)then
        Timer.Wait 'ability_thdots_mokou04_cooldown' (8.1-ability:GetLevel(),
          function()
            mokouAbility:StartCooldown(mokouCooldown-ability:GetLevel())
          end
        )
      end
    end 
    if(mokouAbility1:GetLevel()>0)then
      local mokouCooldown1 = mokouAbility1:GetCooldownTimeRemaining()
      if(mokouCooldown1>=0)then
        Timer.Wait 'ability_thdots_mokou04_cooldown' (8.1-ability:GetLevel(),
        function()
          mokouAbility1:StartCooldown(mokouCooldown1-ability:GetLevel())
        end
        )
      end
    end 
  end
  --PrintTable(keys)
end
function THDOTSGameMode:AbilityLearn(keys)
	local ply = EntIndexToHScript(keys.player)
	local caster = ply:GetAssignedHero()
	--[[PrintTable(weapons)
	for _,v in pairs(weapons) do
		v:DetachFromParent()
    end]]--
end

function THDOTSGameMode:CleanupPlayer(keys)
  print('[DOTA2X] Player Disconnected ' .. tostring(keys.userid))
end

function THDOTSGameMode:CloseServer()
  -- 发送一个指令到服务器，指令内容为exit，告知服务器退出
  -- 可以在服务器里面尝试打exit，就可以知道这个指令是什么效果了
  SendToServerConsole('exit')
end

function THDOTSGameMode:PlayerConnect(keys)
  --PrintTable(keys)
  self.vUserNames[keys.userid] = keys.name
  if keys.bot == 1 then
    self.vBots[keys.userid] = 1
  end
end

local hook = nil
local attach = 0
local controlPoints = {}
local particleEffect = ""

function THDOTSGameMode:PlayerSay(keys)
  --PrintTable(keys)
  local ply = self.vUserIds[keys.userid]
  if ply == nil then
    return
  end
  -- 获取玩家的ID，0-9
  local plyID = ply:GetPlayerID()
  -- 检验是否有效玩家
  if not PlayerResource:IsValidPlayer(plyID) then
    return
  end
  -- 获取所说内容
  -- text这个key可以在上方通过PrintTable在控制台看到
  local text = keys.text
  -- 如果文本符合 -swap 1 3这样的内容
  local matchA, matchB = string.match(text, "^-swap%s+(%d)%s+(%d)")
  if matchA ~= nil and matchB ~= nil then
    -- 那么就，做点什么
  end
  
end

function THDOTSGameMode:AutoAssignPlayer(keys)
	--PrintTable(keys)
	-- 这里调用CaptureGameMode这个函数，执行游戏模式初始化
	THDOTSGameMode:CaptureGameMode()
  
	-- 这里的index是玩家的index 0-9，但是EntIndexToHScript需要1-10，所以要+1
	local entIndex = keys.index+1
	local ply = EntIndexToHScript(entIndex)

	if(ply~=nil)then
		ply:SetContextThink(DoUniqueString("Thdots_Listen_Select_Hero"),
			function()
				local hero = ply:GetAssignedHero()
				-- 确认已经获取到这个英雄
				if (hero ~= nil) then
					PrecacheHeroResource(hero)
					return nil
				end
				return 0.1
			end
		,0.1)
	end
	
  
  -- 获取玩家的ID
  local playerID = ply:GetPlayerID()
  
  -- 存入相应变量
  self.vUserIds[keys.userid] = ply
  self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply
  
  -- 如果玩家的ID是-1的话，也就是还没有分配玩家阵营，那么就分配一下队伍
  if  playerID == -1 then
    -- 如果天辉玩家数量>夜魇玩家数量
    if #self.vRadiant > #self.vDire then
      -- 那么就把这个玩家分配给夜魇
      ply:SetTeam(DOTA_TEAM_BADGUYS)
      --ply:__KeyValueFromInt('teamnumber', DOTA_TEAM_BADGUYS)
      -- 存入对应的table
      table.insert (self.vDire, ply)
    else
      ply:SetTeam(DOTA_TEAM_GOODGUYS)
      --ply:__KeyValueFromInt('teamnumber', DOTA_TEAM_GOODGUYS)
      table.insert (self.vRadiant, ply)
    end
    playerID = ply:GetPlayerID()
  end

  --[[ 自动分配英雄，使用的依然是Timer
  self:CreateTimer('assign_player_'..entIndex,{
    endTime = Time(),
    callback = function(dota2x, args)
    -- 确定游戏已经开始了（有时候也不必要有这个判断，根据实际情况）
      if GameRules:State_Get() >= DOTA_GAMERULES_STATE_PRE_GAME then
      -- 如果这个玩家没有英雄，那么就给他创建一个
        local heroEntity = ply:GetAssignedHero()
        if heroEntity == nil then
          PlayerResource:CreateHeroForPlayer("npc_dota_hero_axe",ply)
        end
        return Time() + 1.0
      end
	end
})]]--
end

function THDOTSGameMode:LoopOverPlayers(callback)
  for k, v in pairs(self.vPlayers) do
    -- Validate the player
    if IsValidEntity(v.hero) then
      -- Run the callback
      if callback(v, v.hero:GetPlayerID()) then
        break
      end
    end
  end
end

function THDOTSGameMode:ShopReplacement( keys )
  --PrintTable(keys)

  local plyID = keys.PlayerID
  if not plyID then return end

  local itemName = keys.itemname 
  
  local itemcost = keys.itemcost
  
end

function THDOTSGameMode:getItemByName( hero, name )
  for i=0,11 do
    local item = hero:GetItemInSlot( i )
    if item ~= nil then
      local lname = item:GetAbilityName()
      if lname == name then
        return item
      end
    end
  end

  return nil
end

function THDOTSGameMode:Think()
  -- 游戏模式循环执行的函数体

  -- 如果游戏阶段已经是游戏结束，那么也就没有必要循环执行了，return
  if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
    return
  end

  -- 追踪游戏时间，通过GameRules:GetGameTime()来获取，在PreGameTime，获取的就是负值
  local now = GameRules:GetGameTime()
  if THDOTSGameMode.t0 == nil then
    THDOTSGameMode.t0 = now
  end
  local dt = now - THDOTSGameMode.t0
  THDOTSGameMode.t0 = now


  -- 执行Timer的函数
  for k,v in pairs(THDOTSGameMode.timers) do
    local bUseGameTime = false
    if v.useGameTime and v.useGameTime == true then
      bUseGameTime = true;
    end
    -- 检查现在的游戏时间/显示时间是否大于Timer所设定的endTime
    if (bUseGameTime and GameRules:GetGameTime() > v.endTime) or (not bUseGameTime and Time() > v.endTime) then
      -- 如果已经达到了时间，那么就移除这个Timer
      THDOTSGameMode.timers[k] = nil

      -- 执行这个Timer的回调函数
      local status, nextCall = pcall(v.callback, THDOTSGameMode, v)

      -- 确认这个函数已经正确执行
      if status then
        -- 检查这个函数是否需要循环执行
        if nextCall then
          --如果需要循环执行的话，那么就循环执行
          v.endTime = nextCall
          THDOTSGameMode.timers[k] = v
        end

      else
        -- 如果回调函数执行不正确，就调用 HandleEventError这个函数来显示对应的错误信息
        THDOTSGameMode:HandleEventError('Timer', k, nextCall)
      end
    end
  end

  return THINK_TIME
end

function THDOTSGameMode:HandleEventError(name, event, err)
  -- 在控制台显示报错
  print(err)

  -- 指定相关字段
  name = tostring(name or 'unknown')
  event = tostring(event or 'unknown')
  err = tostring(err or 'unknown')

  -- 报出对应错误 - say用来在聊天框显示一段信息，第一个参数指说话者，nil则显示为console
  -- 第二个参数为信息
  -- 第三个为是否队伍聊天，false指代显示给所有人
  Say(nil, name .. ' threw an error on event '..event, false)
  Say(nil, err, false)

  -- 避免同样的一个错误被循环报错
  if not self.errorHandled then
    self.errorHandled = true
  end
end

function THDOTSGameMode:CreateTimer(name, args)
  -- 创建Timer的函数
  -- 如果没有指定endTime和callback，那么就不给存储
  if not args.endTime or not args.callback then
    print("Invalid timer created: "..name)
    return
  end

  -- 将Timer储存进变量
  self.timers[name] = args
end

function THDOTSGameMode:RemoveTimer(name)
  -- 移除Timer只要将table对应的值设定为nil即可
  self.timers[name] = nil
end

function THDOTSGameMode:RemoveTimers(killAll)
  local timers = {}

  -- 判定是否全部移除
  if not killAll then
    -- 遍历全部Timer
    for k,v in pairs(self.timers) do
      -- 检查这个Timer是否是一个循环Timer
      if v.nextCall then
        -- 如果是的话就保留他
        timers[k] = v
      end
    end
  end

  -- 刷新Timer table
  self.timers = timers
end

function THDOTSGameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      
    end
  end

  print( '*********************************************' )
end

function THDOTSGameMode:OnEntityKilled( keys )
	--print( '[DOTA2X] OnEntityKilled Called' )
	--PrintTable( keys )
  
	-- 储存被击杀的单位
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- 储存杀手单位
	local killerEntity = EntIndexToHScript( keys.entindex_attacker )
	
	if(killedUnit:IsHero()==false)then
		local i = RandomInt(0,100)
		if(i<5)then
			local unit = CreateUnitByName(
				"npc_coin_up_unit"
				,killedUnit:GetOrigin()
				,false
				,killedUnit
				,killedUnit
				,DOTA_UNIT_TARGET_TEAM_NONE
				)
			unit:SetThink(
				function()
					unit:RemoveSelf()
					return nil
				end, 
				"ability_collection_power_remove",
			30.0)
		end
		i = RandomInt(0,100)
		if(i<5)then
			local unit = CreateUnitByName(
				"npc_power_up_unit"
				,killedUnit:GetOrigin()
				,false
				,killedUnit
				,killedUnit
				,DOTA_UNIT_TARGET_TEAM_NONE
				)
			unit:SetThink(
				function()
					unit:RemoveSelf()
					return nil
				end, 
				"ability_collection_power_remove",
			30.0)
		end
	end
	
	if(killedUnit:IsHero()==true)then
		local powerStatValue = killedUnit:GetContext("hero_bouns_stat_power_count")
		if(powerStatValue==nil)then
			return
		end
		local powerDecrease = (powerStatValue - powerStatValue%2)/2
		killedUnit:SetContextNum("hero_bouns_stat_power_count",powerStatValue-powerDecrease,0)
		if(killedUnit:GetPrimaryAttribute()==0)then
			 killedUnit:SetBaseStrength(killedUnit:GetBaseStrength()-powerDecrease)
		elseif(killedUnit:GetPrimaryAttribute()==1)then
			 killedUnit:SetBaseAgility(killedUnit:GetBaseAgility()-powerDecrease)
		elseif(killedUnit:GetPrimaryAttribute()==2)then
			 killedUnit:SetBaseIntellect(killedUnit:GetBaseIntellect()-powerDecrease)
		end
		for i= 0,powerDecrease do
			local vecRan = RandomVector(100)
			local power = CreateUnitByName(
				"npc_power_up_unit"
				,killedUnit:GetOrigin()+vecRan
				,false
				,killedUnit
				,killedUnit
				,DOTA_UNIT_TARGET_TEAM_NONE
				)
			power:SetThink(
				function()
					power:RemoveSelf()
					return nil
				end, 
				"ability_collection_power_remove",
			30.0)
		end
	end
  
  if(killerEntity:IsHero()==true)then
    local abilityNecAura = killerEntity:FindAbilityByName("necrolyte_heartstopper_aura")
    if(abilityNecAura~=nil)then
      local abilityLevel = abilityNecAura:GetLevel()
      if(abilityLevel~=nil)then
       killerEntity:SetMana(killerEntity:GetMana()+(abilityLevel*5+5))
      end
    end
  end
end

-- function THDOTSGameMode:GameThink()
--     -- Check to see if the game has finished
--     if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
--         -- Send stats
--         statcollection.sendStats()

--         -- Delete the thinker
--         return
--     else
--         -- Check again in 1 second
--         return 1
--     end
-- end