require("libs.ScriptConfig")
require("libs.Utils")
require("libs.HeroInfo")
local config = ScriptConfig.new()
config:SetParameter("CreepBlockKey", "N", config.TYPE_HOTKEY)
config:SetParameter("DisableAfter30secs", true)
config:Load()	
creepblockkey = config.CreepBlockKey
disableafter30secs = config.DisableAfter30secs
local reg = false local firstmove = false local closestCreep = nil local blocksleep = 0
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText = drawMgr:CreateText(-50,-25,-1,"AutoBlock: Hold ''" .. string.char(creepblockkey) .. "''",F14) statusText.visible = false
local disableText = drawMgr:CreateText(-50,-15,-1,"",F14) disableText.visible = false
local laneText = drawMgr:CreateText(-50,-15,-1,"",F14) laneText.visible = false
local lane = nil
local pressed = false

function Main(tick)
	if not PlayingGame() or client.paused then return end	
	local me = entityList:GetMyHero()
	statusText.entity = me
	statusText.entityPosition = Vector(0,0,me.healthbarOffset)
	disableText.entity = me
	disableText.entityPosition = Vector(0,0,me.healthbarOffset)	
	if client.gameTime > 0 and disableafter30secs then 
		disableText.visible = true
		disableText.text = "Disable in " .. math.floor(30 - client.gameTime) .. " seconds."
	else
		disableText.visible = false
		disableText.text = ""
	end
	if client.gameTime >= 30 and disableafter30secs then
		disableText.visible = false
		statusText.visible = false
		laneText.visible = true
		myId = nil
		closestCreep = nil
		script:Disable()
	else
		statusText.visible = true
		laneText.visible = true
	end	
	local towers = entityList:GetEntities({classId=CDOTA_BaseNPC_Tower,alive=true,team=me.team})
	local startingpoints = {{Vector(-6616,-3746,288), "top"}, {Vector(-4781,-3969,261), "mid"}, {Vector(-3442,-6159,269), "bot"}, {Vector(2941,5750,217), "top"}, {Vector(3929,3420,263), "mid"}, {Vector(6254,3435,256), "bot"}}
	table.sort(towers, function (a,b) return GetDistance2D(a,client.mousePosition) < GetDistance2D(b,client.mousePosition) end)
	if towers[1] and not pressed then 
		for i,v in ipairs(startingpoints) do
			if not lane or GetDistance2D(v[1], towers[1]) < GetDistance2D(lane[1], towers[1]) then
				lane = {v[1],v[2]}
			end
		end
		laneText.entity = towers[1]
		laneText.entityPosition = Vector(0,0,towers[1].healthbarOffset)
		laneText.text = "Block " .. lane[2] .. " lane"
		laneText.visible = true
		laneText.color = -1
	end
	if IsKeyDown(creepblockkey) and not client.chat then
		if not pressed then
			pressed = true
			laneText.color = 0x17E317FF
		end
		local startingpoint = Vector(-4781,-3969,261)
		local startingpoint2 = Vector(-4250,-3983,273)
		local endingpoint = Vector(-1159,-725,132)
		local starttime = 0.48
		local enddistance = 4600
		if lane[2] == "top" then
			startingpoint = Vector(-6616,-3746,288)
			startingpoint2 = Vector(-6578,-3653,288)
			endingpoint = Vector(-6272,2967,256)
			starttime = 0.35
			enddistance = 6500
		elseif lane[2] == "bot" then
			startingpoint = Vector(-3442,-6159,269)
			startingpoint2 = Vector(-3320,-6154,171)
			endingpoint = Vector(5578,-5311,256)
			starttime = 0
			enddistance = 3500
		end
		if me.team == LuaEntity.TEAM_DIRE then
			startingpoint = Vector(3929,3420,263)
			startingpoint2 = Vector(3854,3319,191)
			endingpoint = Vector(116,250,127)
			starttime = 0.35
			enddistance = 4600
			if lane[2] == "top" then
				startingpoint = Vector(2941,5750,217)
				startingpoint2 = Vector(2787,5765,141)
				endingpoint = Vector(-6223,4550,256)
				starttime = 0.35
				enddistance = 4600
			elseif lane[2] == "bot" then
				startingpoint = Vector(6254,3435,256)
				startingpoint2 = Vector(6250,3331,256)
				endingpoint = Vector(6135,-3301,256)
				starttime = 0.35
				enddistance = 4600
			end
		end
		-- print(me.position)
		-- print(startingpoint2)
		if client.gameTime >= (starttime - client.latency/1000 - (GetDistance2D(startingpoint,startingpoint2)/me.movespeed)/10) then
			if isPosEqual(me.position, startingpoint2, 3) or Vector(me.position.x, me.position.y, 0) == Vector(startingpoint2.x, startingpoint2.y, 0) or GetDistance2D(endingpoint,me) < 4000 then
				firstmove = true
			end
			if not firstmove then 
				if SleepCheck("firstmove") then
					me:Move(startingpoint2) 
					Sleep(125, "firstmove")
				end
			elseif tick > blocksleep then
				for creepHandle, creep in ipairs(entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,alive=true,visible=true,team=me.team})) do	
					if creep.spawned and creep.health > 0 and GetDistance2D(me,creep) < 650 then
						local alfa, move, p
						if starttime == 0.48 and GetDistance2D(creep, startingpoint) < 100 then
							Sleep(6000 + client.latency/1000 + ((me.movespeed/creep.movespeed)/(creep.movespeed/me.movespeed)), "stop")
							print("Detected RTZ block failure!")
						end
						if not closestCreep or (GetDistance2D(creep,endingpoint) - 25) < GetDistance2D(closestCreep,endingpoint) or GetDistance2D(me,closestCreep) > 500 then
							closestCreep = creep
						end
						if closestCreep and GetDistance2D(me,closestCreep) <= 500 then
							alfa = closestCreep.rotR
							move = Vector(me.position.x + me.movespeed * math.cos(me.rotR), me.position.y + me.movespeed * math.sin(me.rotR), me.position.y)
							p = Vector(closestCreep.position.x + closestCreep.movespeed * (closestCreep.movespeed/me.movespeed) * math.cos(alfa), closestCreep.position.y + closestCreep.movespeed * (closestCreep.movespeed/me.movespeed) * math.sin(alfa), closestCreep.position.z)
							if (GetDistance2D(creep.position, endingpoint) - 50 - GetDistance2D(closestCreep.position, endingpoint)) <= 0 and creep.handle ~= closestCreep.handle then
								alfa = creep.rotR
								p = Vector(creep.position.x + creep.movespeed * (creep.movespeed/me.movespeed) * math.cos(alfa), creep.position.y + creep.movespeed * (creep.movespeed/me.movespeed) * math.sin(alfa), creep.position.z)
							end
							--if SleepCheck("block") and GetDistance2D(p, endingpoint) <= GetDistance2D(me, endingpoint) then
								me:Move(p)
								--if GetDistance2D(me, closestCreep) > (100 + client.latency/1000) and (GetDistance2D(creep,endingpoint) - 100) > GetDistance2D(closestCreep,endingpoint) then
									--Sleep((GetDistance2D(move,closestCreep)/closestCreep.movespeed)*((me.movespeed/creep.movespeed)/(creep.movespeed/me.movespeed)) - client.latency/1000, "block")
								--end
							--end
							if GetDistance2D(endingpoint,me) < enddistance and GetDistance2D(me, closestCreep) > (25 + client.latency/1000) and (GetDistance2D(me,endingpoint) + 50) < GetDistance2D(closestCreep,endingpoint) and (GetDistance2D(creep,endingpoint) - 50) > GetDistance2D(closestCreep,endingpoint) and SleepCheck("stop") then
								me:Stop()
								Sleep((GetDistance2D(me,creep)/creep.movespeed)*(creep.movespeed/me.movespeed) - (GetDistance2D(me,closestCreep)/closestCreep.movespeed)*(closestCreep.movespeed/me.movespeed) - (math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, p))) - 0.69, 0)/(heroInfo[me.name].turnRate*(1/0.03))), "stop")
							end
							if blocksleep <= tick then
								blocksleep = tick + (me.movespeed/2)*(me.movespeed/closestCreep.movespeed) + GetDistance2D(me, p)/me.movespeed + client.latency/1000 - (math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, p))) - 0.69, 0)/(heroInfo[me.name].turnRate*(1/0.03)))
							end
						end
					end
				end
			end
		elseif client.gameTime < 0 and not (isPosEqual(me.position, startingpoint, 3) or me.position == startingpoint) and SleepCheck("move") then
			me:Move(startingpoint) Sleep(1000,"move")
		end
	end
end

function Length(v1, v2)
	return (v1-v2).length
end

function isPosEqual(v1, v2, d)
    return (v1-v2).length <= d
end

function FindAngleR(entity)
	if entity.rotR < 0 then
		return math.abs(entity.rotR)
	else
		return 2 * math.pi - entity.rotR
	end
end

function FindAngleBetween(first, second)
	local xAngle = math.deg(math.atan(math.abs(second.x - first.position.x)/math.abs(second.y - first.position.y)))
	if first.position.x <= second.x and first.position.y >= second.y then
		return 90 - xAngle
	elseif first.position.x >= second.x and first.position.y >= second.y then
		return xAngle + 90
	elseif first.position.x >= second.x and first.position.y <= second.y then
		return 90 - xAngle + 180
	elseif first.position.x <= second.x and first.position.y <= second.y then
		return xAngle + 90 + 180
	end
	return nil
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then 
			script:Disable()
		else
			statusText.visible = false
			disableText.visible = false
			laneText.visible = false
			reg = true
			firstmove = false
			closestCreep = nil
			blocksleep = 0
			lane = nil
			pressed = false
			script:RegisterEvent(EVENT_TICK, Main)
			script:UnregisterEvent(Load)
		end
	end	
end

function Close()
	statusText.visible = false
	disableText.visible = false
	laneText.visible = false
	closestCreep = nil
	pressed = false
	if reg then
		script:UnregisterEvent(Main)
		script:RegisterEvent(EVENT_TICK, Load)	
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)
