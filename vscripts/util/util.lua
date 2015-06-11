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

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'



--============ Copyright (c) Valve Corporation, All rights reserved. ==========
--
--
--=============================================================================

--/////////////////////////////////////////////////////////////////////////////
-- Debug helpers
--
--  Things that are really for during development - you really should never call any of this
--  in final/real/workshop submitted code
--/////////////////////////////////////////////////////////////////////////////

-- if you want a table printed to console formatted like a table (dont we already have this somewhere?)
scripthelp_LogDeepPrintTable = "Print out a table (and subtables) to the console"
logFile = "log/log.txt"

function LogDeepSetLogFile( file )
	logFile = file
end

function LogEndLine ( line )
	AppendToLogFile(logFile, line .. "\n")
end

function _LogDeepPrintMetaTable( debugMetaTable, prefix )
	_LogDeepPrintTable( debugMetaTable, prefix, false, false )
	if getmetatable( debugMetaTable ) ~= nil and getmetatable( debugMetaTable ).__index ~= nil then
		_LogDeepPrintMetaTable( getmetatable( debugMetaTable ).__index, prefix )
	end
end

function _LogDeepPrintTable(debugInstance, prefix, isOuterScope, chaseMetaTables ) 
    prefix = prefix or ""
    local string_accum = ""
    if debugInstance == nil then 
		LogEndLine( prefix .. "<nil>" )
		return
    end
	local terminatescope = false
	local oldPrefix = ""
    if isOuterScope then  -- special case for outer call - so we dont end up iterating strings, basically
        if type(debugInstance) == "table" then 
            LogEndLine( prefix .. "{" )
			oldPrefix = prefix
            prefix = prefix .. "   "
			terminatescope = true
        else 
            LogEndLine( prefix .. " = " .. (type(debugInstance) == "string" and ("\"" .. debugInstance .. "\"") or debugInstance))
        end
    end
    local debugOver = debugInstance

	-- First deal with metatables
	if chaseMetaTables == true then
		if getmetatable( debugOver ) ~= nil and getmetatable( debugOver ).__index ~= nil then
			local thisMetaTable = getmetatable( debugOver ).__index 
			if vlua.find(_LogDeepprint_alreadyseen, thisMetaTable ) ~= nil then 
				LogEndLine( string.format( "%s%-32s\t= %s (table, already seen)", prefix, "metatable", tostring( thisMetaTable ) ) )
			else
				LogEndLine(prefix .. "metatable = " .. tostring( thisMetaTable ) )
				LogEndLine(prefix .. "{")
				table.insert( _LogDeepprint_alreadyseen, thisMetaTable )
				_LogDeepPrintMetaTable( thisMetaTable, prefix .. "   ", false )
				LogEndLine(prefix .. "}")
			end
		end
	end

	-- Now deal with the elements themselves
	-- debugOver sometimes a string??
    for idx, data_value in pairs(debugOver) do
        if type(data_value) == "table" then 
            if vlua.find(_LogDeepprint_alreadyseen, data_value) ~= nil then 
                LogEndLine( string.format( "%s%-32s\t= %s (table, already seen)", prefix, idx, tostring( data_value ) ) )
            else
                local is_array = #data_value > 0
				local test = 1
				for idx2, val2 in pairs(data_value) do
					if type( idx2 ) ~= "number" or idx2 ~= test then
						is_array = false
						break
					end
					test = test + 1
				end
				local valtype = type(data_value)
				if is_array == true then
					valtype = "array table"
				end
                LogEndLine( string.format( "%s%-32s\t= %s (%s)", prefix, idx, tostring(data_value), valtype ) )
                LogEndLine(prefix .. (is_array and "[" or "{"))
                table.insert(_LogDeepprint_alreadyseen, data_value)
                _LogDeepPrintTable(data_value, prefix .. "   ", false, true)
                LogEndLine(prefix .. (is_array and "]" or "}"))
            end
		elseif type(data_value) == "string" then 
            LogEndLine( string.format( "%s%-32s\t= \"%s\" (%s)", prefix, idx, data_value, type(data_value) ) )
		else 
            LogEndLine( string.format( "%s%-32s\t= %s (%s)", prefix, idx, tostring(data_value), type(data_value) ) )
        end
    end
	if terminatescope == true then
		LogEndLine( oldPrefix .. "}" )
	end
end


function LogDeepPrintTable( debugInstance, prefix, isPublicScriptScope ) 
    prefix = prefix or ""
    _LogDeepprint_alreadyseen = {}
    table.insert(_LogDeepprint_alreadyseen, debugInstance)
    _LogDeepPrintTable(debugInstance, prefix, true, isPublicScriptScope )
end


--/////////////////////////////////////////////////////////////////////////////
-- Fancy new LogDeepPrint - handles instances, and avoids cycles
--
--/////////////////////////////////////////////////////////////////////////////

-- @todo: this is hideous, there must be a "right way" to do this, im dumb!
-- outside the recursion table of seen recurses so we dont cycle into our components that refer back to ourselves
_LogDeepprint_alreadyseen = {}


-- the inner recursion for the LogDeep print
function _LogDeepToString(debugInstance, prefix) 
    local string_accum = ""
    if debugInstance == nil then 
        return "LogDeep Print of NULL" .. "\n"
    end
    if prefix == "" then  -- special case for outer call - so we dont end up iterating strings, basically
        if type(debugInstance) == "table" or type(debugInstance) == "table" or type(debugInstance) == "UNKNOWN" or type(debugInstance) == "table" then 
            string_accum = string_accum .. (type(debugInstance) == "table" and "[" or "{") .. "\n"
            prefix = "   "
        else 
            return " = " .. (type(debugInstance) == "string" and ("\"" .. debugInstance .. "\"") or debugInstance) .. "\n"
        end
    end
    local debugOver = type(debugInstance) == "UNKNOWN" and getclass(debugInstance) or debugInstance
    for idx, val in pairs(debugOver) do
        local data_value = debugInstance[idx]
        if type(data_value) == "table" or type(data_value) == "table" or type(data_value) == "UNKNOWN" or type(data_value) == "table" then 
            if vlua.find(_LogDeepprint_alreadyseen, data_value) ~= nil then 
                string_accum = string_accum .. prefix .. idx .. " ALREADY SEEN " .. "\n"
            else 
                local is_array = type(data_value) == "table"
                string_accum = string_accum .. prefix .. idx .. " = ( " .. type(data_value) .. " )" .. "\n"
                string_accum = string_accum .. prefix .. (is_array and "[" or "{") .. "\n"
                table.insert(_LogDeepprint_alreadyseen, data_value)
                string_accum = string_accum .. _LogDeepToString(data_value, prefix .. "   ")
                string_accum = string_accum .. prefix .. (is_array and "]" or "}") .. "\n"
            end
        else 
            --string_accum = string_accum .. prefix .. idx .. "\t= " .. (type(data_value) == "string" and ("\"" .. data_value .. "\"") or data_value) .. "\n"
			string_accum = string_accum .. prefix .. idx .. "\t= " .. "\"" .. tostring(data_value) .. "\"" .. "\n"
        end
    end
    if prefix == "   " then 
        string_accum = string_accum .. (type(debugInstance) == "table" and "]" or "}") .. "\n" -- hack for "proving" at end - this is DUMB!
    end
    return string_accum
end


scripthelp_LogDeepString = "Convert a class/array/instance/table to a string"

function LogDeepToString(debugInstance, prefix) 
    prefix = prefix or ""
    _LogDeepprint_alreadyseen = {}
    table.insert(_LogDeepprint_alreadyseen, debugInstance)
    return _LogDeepToString(debugInstance, prefix)
end


scripthelp_LogDeepPrint = "Print out a class/array/instance/table to the console"

function LogDeepPrint(debugInstance, prefix) 
    prefix = prefix or ""
    LogEndLine(LogDeepToString(debugInstance, prefix))
end

function GetDistanceBetweenTwoVec2D(a, b)
    local xx = (a.x-b.x)
    local yy = (a.y-b.y)
    return math.sqrt(xx*xx + yy*yy)
end

function GetRadBetweenTwoVec2D(a,b)
	local y = b.y - a.y
	local x = b.x - a.x
	return math.atan2(y,x)
end
--aVec:原点向量
--rectOrigin：单位原点向量
--rectWidth：矩形宽度
--rectLenth：矩形长度
--rectRad：矩形相对Y轴旋转角度
function IsRadInRect(aVec,rectOrigin,rectWidth,rectLenth,rectRad)
	local aRad = GetRadBetweenTwoVec2D(rectOrigin,aVec)
	local turnRad = aRad + (math.pi/2 - rectRad)
	local aRadius = GetDistanceBetweenTwoVec2D(rectOrigin,aVec)
	local turnX = aRadius*math.cos(turnRad)
	local turnY = aRadius*math.sin(turnRad)
	local maxX = rectWidth/2
	local minX = -rectWidth/2
	local maxY = rectLenth
	local minY = 0
	if(turnX<maxX and turnX>minX and turnY>minY and turnY<maxY)then
		return true
	else
	    return false
	end
	return false
end

function IsRadBetweenTwoRad2D(a,rada,radb)
	local math2pi = math.pi * 2
	rada = rada + math2pi
	radb = radb + math2pi
	a = a + math2pi
	local maxrad = math.max(rada,radb)
	local minrad = math.min(rada,radb)
	if(a<maxrad and a>minrad)then
		return true
	end
	return false
end

function SetTargetToTraversable(target)
    local vecTarget = target:GetOrigin() 
    local vecGround = GetGroundPosition(vecTarget, nil)

    UnitNoCollision(target,target,0.1)
end

function RemoveWearables( hero )
    --print("RemoveWearables")
    -- 储存英雄的所有饰品的表
    local wearables = {}
    -- 获取英雄的第一个子模型
    local model = hero:FirstMoveChild()
    -- 循环所有模型
    while model ~= nil do
        -- 确保获取到的是 dota_item_wearable 的模型
        if model ~= nil and model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" then
            --print(model:GetModelName())
            -- 这里是因为要去掉的是weapon，所以有了这么一个判断
            -- 如果你是要去掉所有的饰品，就不用这个if
            -- 具体你可以根据获取的GetModelName()
            -- 来判定是否需要去掉
            --if string.find(model:GetModelName(), "weapon") ~= nil then --or string.find(model:GetModelName(), "horns") ~= nil then
                table.insert(wearables, model)
            --end
        end
        -- 获取下一个模型
        model = model:NextMovePeer()
    end

    if #wearables >=1 then
        -- 循环所有的模型，并移除
        for i = 1, #wearables do
            --print("removed 1 wearable")
            wearables[i]:RemoveSelf()
        end
        --hero:RespawnHero( false, false, false)
    else
        return
    end
end
 
function AttachWearables( hero )
    -- 要添加的饰品模型
    weaponModel = "models/heroes/terrorblade/weapon.vmdl"
    -- 创建模型实体
    local weapon = Entities:CreateByClassname("dota_item_wearable")
    -- 更改实体模型
    weapon:SetModel(weaponModel)
    -- 绑定到单位
    weapon:SetParent(hero, "attach_weapon_r")
end

function ParticleManager:DestroyParticleSystem(effectIndex,bool)
    if(bool)then
        ParticleManager:DestroyParticle(effectIndex,true)
        ParticleManager:ReleaseParticleIndex(effectIndex) 
    else
        Timer.Wait 'Effect_Destroy_Particle' (4,
            function()
                ParticleManager:DestroyParticle(effectIndex,true)
                ParticleManager:ReleaseParticleIndex(effectIndex) 
            end
        )
    end
<<<<<<< HEAD
end

function ParticleManager:DestroyParticleSystemTime(effectIndex,time)
    Timer.Wait 'Effect_Destroy_Particle_Time' (time,
        function()
            ParticleManager:DestroyParticle(effectIndex,true)
            ParticleManager:ReleaseParticleIndex(effectIndex) 
        end
    )
end

--[[Author: Noya
 Date: 10.01.2015.
 Hides dem hats
]]
function HideWearables( hero )
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
             print("Hidden Model:"..modelName.."")
 
             -- Set model invisible
             model:SetModel("models/development/invisiblebox.vmdl")
             table.insert(hero.hiddenWearables,model)
            end
        end
        model = model:NextMovePeer()
        if model ~= nil then
            print("Next Peer:" .. model:GetModelName())
        end
    end
end
 
--[[Author: Noya
 Date: 10.01.2015.
 Shows the hidden hero wearables
]]
function ShowWearables( hero )
 print("Showing Wearables on ".. hero:GetModelName())
 
 -- Iterate on both tables to set each item back to their original modelName
 for i,v in ipairs(hero.hiddenWearables) do
  for index,modelName in ipairs(hero.wearableNames) do
   if i==index then
    print("Changed "..v:GetModelName().. " back to "..modelName)
    v:SetModel(modelName)
   end
 
   -- Here we can also change to any different cosmetic we want, in the proper slot
   if v:GetModelName() == "models/heroes/abaddon/weapon.vmdl" then
    v:SetModel("models/items/abaddon/feathers/feathers_weapon.vmdl")
   end
 
   if v:GetModelName() == "models/heroes/abaddon/mount.vmdl" then
    v:SetModel("models/items/abaddon/mount_drake_evercold/mount_drake_evercold.vmdl")
   end
 
   if v:GetModelName() == "models/heroes/abaddon/cape.vmdl" then
    v:SetModel("models/items/abaddon/hood_of_the_font_guard/hood_of_the_font_guard.vmdl")
   end
 
   if v:GetModelName() == "models/heroes/abaddon/shoulders.vmdl" then
    v:SetModel("models/items/abaddon/winged_shroud_of_ruin/winged_shroud_of_ruin.vmdl")
   end
 
   if v:GetModelName() == "models/heroes/abaddon/mount.vmdl" then
    v:SetModel("models/items/abaddon/feathers/feathers_weapon.vmdl")
   end
 
  end
 end
end

=======
end
>>>>>>> origin/master
