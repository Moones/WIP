require("libs.ScriptConfig")
require("libs.Utils")

local config = ScriptConfig.new()
config:SetParameter("SelectWolf1", 49, config.TYPE_HOTKEY) -- 49 is Key Code for 1
config:SetParameter("SelectWolf2", 50, config.TYPE_HOTKEY) -- 50 is Key Code for 2 for all KeyCodes go to http://www.zynox.net/forum/threads/336-KeyCodes
config:SetParameter("UnAggro", 16, config.TYPE_HOTKEY) -- 16 is Key Code for Shift, Holding UnAggro Key + SelectWolf key will make wolf to unaggro himself instantly.
config:Load()	

selectwolf1 = config.SelectWolf1
selectwolf2 = config.SelectWolf2
unaggro = config.UnAggro

local reg = false
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",18*monitor,550*monitor) 
local wolf1, wolf2
local wolftext1 = drawMgr:CreateText(-10,-25,-1,"1",F14) wolftext1.visible = false
local wolftext2 = drawMgr:CreateText(-10,-25,-1,"2",F14) wolftext2.visible = false
local sleep = 0

function Main(tick)
	if not PlayingGame() or tick < sleep then return end
	sleep = tick + 100
	local me = entityList:GetMyHero()
	local wolves = entityList:GetEntities({classId=291, controllable=true, team=me.team, alive=true})
	if #wolves > 0 then
		if wolves[1] and not wolf1 then
			wolf1 = wolves[1]
			wolftext1.visible = true
			wolftext1.entity = wolves[1]
			if wolves[1].healthbarOffset ~= -1 then
				wolftext1.entityPosition = Vector(0,0,wolves[1].healthbarOffset)
			else
				wolftext1.entityPosition = Vector(0,0,160)
			end
		elseif not wolves[1] then
			wolftext1.visible = false
			wolf1 = nil
		end
		if wolves[2] and not wolf2 then
			wolf2 = wolves[2]
			wolftext2.visible = true
			wolftext2.entity = wolves[2]
			if wolves[2].healthbarOffset ~= -1 then
				wolftext2.entityPosition = Vector(0,0,wolves[2].healthbarOffset)
			else
				wolftext2.entityPosition = Vector(0,0,160)
			end
		elseif not wolves[2] then
			wolftext2.visible = false
			wolf2 = nil
		end
	end
	if (wolf1 and not wolf1.alive) or not wolf1 then
		wolftext1.visible = false
		wolf1 = nil
		collectgarbage("collect")
	end
	if (wolf2 and not wolf2.alive) or not wolf2 then
		wolftext2.visible = false
		wolf2 = nil
		collectgarbage("collect")
	end
	if IsKeyDown(selectwolf1) and wolf1 then
		if IsKeyDown(unaggro) then
			if SleepCheck("wolf1") then
				wolf1:Attack(me)
				Sleep(500, "wolf1")
			end
		else
			SelectUnit(wolf1)
		end
	end
	if IsKeyDown(selectwolf2) and wolf2 then
		if IsKeyDown(unaggro) then
			if SleepCheck("wolf2") then
				wolf2:Attack(me)
				Sleep(500, "wolf2")
			end
		else
			SelectUnit(wolf2)
		end
	end	
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Lycan then 
			script:Disable()
		else
			wolf1, wolf2 = nil, nil
			reg = true
			script:RegisterEvent(EVENT_TICK, Main)
			script:UnregisterEvent(Load)
		end
	end	
end

function Close()
	wolf1, wolf2 = nil, nil
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Main)
		script:RegisterEvent(EVENT_TICK, Load)	
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)
