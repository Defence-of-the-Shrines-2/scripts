-- 这个文件是RPG载入的时候，游戏的主程序最先载入的文件
-- 一般在这里载入各种我们所需要的各种lua文件
-- 除了addon_game_mode以外，其他的部分都需要去掉

print ( '[[THDOTS]] ADDON INIT EXECUTED' )

-- 这个函数其实就是一个pcall，通过这个函数载入lua文件，就可以在载入的时候通过报错发现程序哪里错误了
-- 避免游戏直接崩溃的情况

local function loadModule(name)
    local status, err = pcall(function()
        -- Load the module
        require(name)
    end)

    if not status then
        -- Tell the user about it
        print('WARNING: '..name..' failed to load!')
        print(err)
    end
end

function Precache( context )
	
	PrecacheResource( "model", "models/thd2/point.vmdl", context )--真の点数
	PrecacheResource( "model", "models/thd2/power.vmdl", context )--真のP点
	PrecacheResource( "model", "models/development/invisiblebox.vmdl", context )
	PrecacheResource( "model", "models/thd2/iku/iku_lightning_drill.vmdl", context )
	PrecacheResource( "particle", "particles/items_fx/aegis_respawn_spotlight.vpcf",context )--真のP点
	PrecacheResource( "particle", "particles/units/heroes/hero_mirana/mirana_base_attack.vpcf",context )--永琳弹道
	PrecacheResource( "particle", "particles/items2_fx/hand_of_midas.vpcf",context )--真の点数
	PrecacheResource( "particle_folder", "particles/thd2/heroes/reimu", context )--灵梦and跳台
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_visage.vsndevts", context )--灵梦and跳台

	PrecacheResource( "model", "models/thd2/yyy.vmdl", context )--灵梦D
	PrecacheResource( "model", "models/thd2/fantasy_seal.vmdl", context )--灵梦F

	PrecacheResource( "model", "models/thd2/youmu/youmu.vmdl", context )--妖梦R

	PrecacheResource( "particle", "particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_fallback_low_egset.vpcf", 
	context )--天子F
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context )--天子W
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_zuus", context )--天子W

	PrecacheResource( "model", "models/props_gameplay/rune_haste01.vmdl", context )--魔理沙R
	PrecacheResource( "model", "models/thd2/masterspark.vmdl", context )--魔理沙 魔炮
	
	PrecacheResource( "particle", "particles/dire_fx/tower_bad_face_end_shatter.vpcf", context )--幽幽子F
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_death_prophet", context )--幽幽子D
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_bane", context )--幽幽子F
	PrecacheResource( "model", "models/thd2/yuyuko_fan.vmdl", context )--幽幽子W

	PrecacheResource( "particle_folder", "particles/units/heroes/hero_phoenix", context )--妹红R	
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context )--妹红R
	PrecacheResource( "model", "models/thd2/firewing.vmdl", context )--妹红W	

	PrecacheResource( "particle", "particles/thd2/heroes/flandre/ability_flandre_04_buff.vpcf", context )--芙兰朵露	
	PrecacheResource( "particle", "particles/thd2/heroes/flandre/ability_flandre_04_effect.vpcf", context )--芙兰朵露

	PrecacheResource( "particle_folder", "particles/units/heroes/hero_brewmaster", context )--红三
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", context )--红三

	PrecacheResource( "particle_folder", "particles/units/heroes/hero_tiny", context )--西瓜
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", context )--西瓜

	PrecacheResource( "particle_folder", "particles/units/heroes/hero_night_stalker", context )--露米娅
	
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_disruptor", context )--永琳
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_disruptor.vsndevts", context )--永琳

	PrecacheResource( "particle", "particles/thd2/items/item_ballon.vpcf", context )--幽灵气球
	PrecacheResource( "particle", "particles/thd2/items/item_bad_man_card.vpcf", context )--坏人卡
	PrecacheResource( "particle", "particles/thd2/items/item_good_man_card.vpcf", context )--好人卡
	PrecacheResource( "particle", "particles/thd2/items/item_love_man_card.vpcf", context )--爱人卡
	PrecacheResource( "particle", "particles/thd2/items/item_unlucky_man_card.vpcf", context )--衰人卡
	PrecacheResource( "particle", "particles/units/heroes/hero_lich/lich_ambient_frost_legs.vpcf", context )--冰青蛙减速
	PrecacheResource( "particle", "particles/thd2/items/item_kafziel.vpcf", context )--镰刀
	PrecacheResource( "particle", "particles/base_attacks/ranged_tower_good_launch.vpcf", context )--绿刀
	PrecacheResource( "particle", "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf", context )--绿坝
	PrecacheResource( "particle", "particles/units/heroes/hero_brewmaster/brewmaster_windwalk.vpcf", context )--碎骨笛
	PrecacheResource( "particle", "particles/thd2/items/item_camera.vpcf", context )--相机
	PrecacheResource( "particle", "particles/thd2/items/item_tsundere.vpcf", context )--无敌
	
	
end

-- 载入项目所有文件
loadModule ( 'thdots' )
loadModule ( 'util/damage' )
loadModule ( 'util/stun' )
loadModule ( 'util/pauseunit' )
loadModule ( 'util/silence' )
loadModule ( 'util/magic_immune' )
loadModule ( 'util/timers' )
loadModule ( 'util/util' )
loadModule ( 'util/disarmed' )
loadModule ( 'util/invulnerable' )
loadModule ( 'util/graveunit' )
loadModule ( 'util/collision' )
loadModule ( 'util/nodamage' )



-- 在执行完这个文件，和我们上面所LoadModule之后，
-- dota2的build_slave的vlua.cpp就会开始执行addon_game_mode.lua

-- 这里我们只写一个内容，DOTA2XGameMode:初始化
THDOTSGameMode:InitGameMode()
