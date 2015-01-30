--WIP version might bug, ensage is too slow to detect crit animation quickly enough so with fast attack speed it wont work.

require("libs.Animations")
require("libs.Utils")
require("libs.TargetFind")

local attack = 0
local move = 0
local haveCrited = false
local victim = nil
local start = false

function Tick(tick)
	if not PlayingGame() or Animations.maxCount < 1 then haveCrited = false victim = nil start = false return end
	
	local waitPercent = 100 --setting to lower value will speed up canceling but might bug, 100 will disable the script
	
	local me = entityList:GetMyHero() 
	if IsKeyDown(0x20) then
		if not start or (not victim or not victim.alive) then
			start = true
			local lowestHP = targetFind:GetLowestEHP(3000, phys)
			if lowestHP and SleepCheck("victim") then			
				victim = lowestHP
				Sleep(250,"victim")
				return
			end
			if not victim or not victim.hero then 					
				local creeps = entityList:GetEntities(function (v) return (v.courier or (v.creep and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Neutral and v.spawned) or 
				v.classId == CDOTA_BaseNPC_Tower or v.classId == CDOTA_BaseNPC_Venomancer_PlagueWard or v.classId == CDOTA_BaseNPC_Warlock_Golem or 
				(v.classId == CDOTA_BaseNPC_Creep_Lane and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Siege and v.spawned) or v.classId == CDOTA_Unit_VisageFamiliar or 
				v.classId == CDOTA_Unit_Undying_Zombie or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_Unit_Broodmother_Spiderling or v.classId == CDOTA_Unit_Hero_Beastmaster_Boar 
				or v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_BaseNPC_Creep) and v.team ~= me.team and v.alive and v.health > 0 and 
				me:GetDistance2D(v) <= math.max(me.attackRange*2+50,500) end)
				if #creeps > 1 then
					table.sort(creeps, function (a,b) return a.health < b.health end)
				end
				if creeps[1] then
					victim = creeps[1]
					return
				end
			end
		end
		if victim and victim.alive and not haveCrited and SleepCheck("attack") then
			if client.gameTime > attack then
				if Animations.isCriting(me) then
					haveCrited = true
					start = false
					Sleep((Animations.GetAttackTime(me) + Animations.getBackswingTime(me) - Animations.getAttackDuration(me))*1000, "attack")
					Sleep((Animations.GetAttackTime(me))*1000)
					return
				end			
				if not Animations.isAttacking(me) then
					me:Attack(victim)
					attack = client.gameTime + (Animations.GetAttackTime(me)/100)*waitPercent
				end
				if not Animations.isCriting(me) then	
					me:Stop()
					attack = client.gameTime + (Animations.GetAttackTime(me)/100)*waitPercent
				end		
			end
		elseif client.gameTime > move and SleepCheck() and not Animations.isCriting(me) then
			if not Animations.CanMove(me) then
				haveCrited = false
				return
			end
			me:Move(client.mousePosition)
			move = client.gameTime + 0.05
		end
	end
end

script:RegisterEvent(EVENT_FRAME,Tick)
