require("libs.ScriptConfig")
require("libs.Utils")
require("libs.HeroInfo")
local config = ScriptConfig.new()
config:SetParameter("CreepBlockKey", "N", config.TYPE_HOTKEY)
config:SetParameter("DisableAfter30secs", true)
config:Load()	
creepblockkey = config.CreepBlockKey
disableafter30secs = config.DisableAfter30secs
local reg = false local firstmove = false local closestCreep = nil local blocksleep = 0 local count = 0 local eff = {} local closestCreep2 = nil
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
		local endingpoint = Vector(-359,-116,13)
		local starttime = 0.48
		local enddistance = 5600
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
				enddistance = 3500
			elseif lane[2] == "bot" then
				startingpoint = Vector(6254,3435,256)
				startingpoint2 = Vector(6250,3331,256)
				endingpoint = Vector(6135,-3301,256)
				starttime = 0.35
				enddistance = 6500
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
				--local creeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,alive=true,visible=true,team=me.team})
				local creeps = entityList:GetEntities(function (ent) return ent.classId == CDOTA_BaseNPC_Creep_Lane and ent.alive == true and ent.visible == true and ent.spawned == true and ent.team == me.team and GetDistance2D(me,ent) < 350 end)
				local count = 1
				closestCreep2 = nil
				closestCreep = nil
				for creepHandle, creep in ipairs(creeps) do	
					if creep.spawned and creep.health > 0 then
						if starttime == 0.48 and GetDistance2D(creep, startingpoint) < 150 then
							Sleep(5000 + client.latency/1000 + ((me.movespeed/creep.movespeed)/(creep.movespeed/me.movespeed)), "stop")
							print("Detected RTZ block failure!")
						end
						if GetDistance2D(me,creep) < 500 then
							if not closestCreep2 then 
								closestCreep2 = {} 
								closestCreep2.position = creep.position
								closestCreep2.rotR = creep.rotR
								closestCreep2.movespeed = creep.movespeed
							else
								count = count + 1
								closestCreep2.position = closestCreep2.position + creep.position
								closestCreep2.rotR = closestCreep2.rotR + creep.rotR
							end
							if not closestCreep or (GetDistance2D(creep,endingpoint) - 50) < GetDistance2D(closestCreep,endingpoint) or GetDistance2D(me,closestCreep) > 500 then
								closestCreep = creep
							end
						end
					end
				end
				if closestCreep2 then
					closestCreep2.position = (closestCreep2.position + closestCreep.position)/(#creeps + 1)
					closestCreep2.rotR = closestCreep2.rotR/#creeps
					if not eff[2] then
						eff[2] = Effect(closestCreep2.position,"range_display")
						eff[2]:SetVector(1, Vector(50,0,0) )
						eff[2]:SetVector(0, closestCreep2.position )
					else
						eff[2]:SetVector(0, closestCreep2.position )
					end
					if GetDistance2D(me,closestCreep2.position) <= 700 then
						local alfa, move, p
						alfa = closestCreep.rotR
						move = Vector(me.position.x + me.movespeed * math.cos(me.rotR), me.position.y + me.movespeed * math.sin(me.rotR), me.position.y)
						p = Vector(closestCreep.position.x + closestCreep.movespeed * (me.movespeed/closestCreep.movespeed) * math.cos(alfa), closestCreep.position.y + closestCreep.movespeed * (closestCreep.movespeed/me.movespeed) * math.sin(alfa), closestCreep.position.z)
						local alfa2 = closestCreep2.rotR
						local p2 = Vector(closestCreep2.position.x + (closestCreep2.movespeed*3) * (me.movespeed/closestCreep2.movespeed) * math.cos(alfa2), closestCreep2.position.y + (closestCreep2.movespeed*3) * (me.movespeed/closestCreep2.movespeed) * math.sin(alfa2), closestCreep2.position.z)
						if not eff[1] then
							eff[1] = Effect(closestCreep.position,"range_display")
							eff[1]:SetVector(1, Vector(100,0,0) )
							eff[1]:SetVector(0, closestCreep.position )
						else
							eff[1]:SetVector(0, closestCreep.position )
						end
						if blocksleep <= tick then
							blocksleep = tick + (me.movespeed/3 * (me.movespeed/closestCreep.movespeed))
						end
						if GetDistance2D(endingpoint,me) < enddistance and GetDistance2D(closestCreep2.position,endingpoint) >= GetDistance2D(closestCreep,endingpoint) and (GetDistance2D(closestCreep,endingpoint) - 25) > GetDistance2D(me,endingpoint) and SleepCheck("stop") then
							me:Stop()
							--Sleep(GetDistance2D(closestCreep,me)/closestCreep.movespeed, "block")
							Sleep(me.movespeed/2 * (closestCreep.movespeed/me.movespeed), "stop")
						end
						if SleepCheck("block") then
							-- if count < 12 then
								-- count = count + 1
							-- else
								-- count = 0
							-- end
							-- if count < 6 and (GetDistance2D(p,p2) < 100 or (GetDistance2D(closestCreep,endingpoint) + 50) < GetDistance2D(me,endingpoint) and (GetDistance2D(closestCreep2.position,endingpoint) - 50) > GetDistance2D(me,endingpoint)) and GetDistance2D(p,endingpoint)+50 < GetDistance2D(me,endingpoint) then
								-- me:Move(p)
							if GetDistance2D(p2,endingpoint)+50 < GetDistance2D(me,endingpoint) then
								me:Move(p2)
							end
						end
					end
				end
			end
		elseif client.gameTime < 0 and not (isPosEqual(me.position, startingpoint, 3) or me.position == startingpoint) and SleepCheck("move") then
			me:Move(startingpoint) Sleep(1000,"move")
		end
	else
		eff[1] = nil
		eff[2] = nil
		collectgarbage("collect")
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
			closestCreep2 = nil
			blocksleep = 0
			lane = nil
			eff = {}
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
	closestCreep2 = nil
	pressed = false
	if reg then
		script:UnregisterEvent(Main)
		script:RegisterEvent(EVENT_TICK, Load)	
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)
