require("libs.ScriptConfig")
require("libs.Utils")
require("libs.TargetFind")
require("libs.Animations")
require("libs.Skillshot")

--[[
                                                  
        +-------------------------------------------------+          
        |                                                 |           
        |        ZweiSpiritsCombo - Made by Moones        |       
        |        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        |     
        +-------------------------------------------------+      
                                                                                 
        =+=+=+=+=+=+=+=+=+ VERSION 0.1 +=+=+=+=+=+=+=+=+=+=
	 
        Description:
        ------------		 
	   
        Changelog:
        ----------
		
]]--

local config = ScriptConfig.new()
config:SetParameter("CustomMove", "J", config.TYPE_HOTKEY)
config:SetParameter("Spaceformove", true)
config:SetParameter("ShowSign", true)
config:Load()
	
custommove = config.CustomMove
spaceformove = config.Spaceformove
showSign = config.ShowSign

sleep = 0

local reg = false local myhero = nil local victim = nil local myId = nil local attack = 0 local move = 0 local start = false local resettime = nil local movetomouse = nil

local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local victimText = drawMgr:CreateText(-50*monitor,1*monitor,-1,"Chasing this guy!",F14) victimText.visible = false

-- function Key(msg, code)
	-- if msg ~= KEY_UP or client.chat or client.console then return end

-- end

function Main(tick)
	if not PlayingGame() then return end
	local me = entityList:GetMyHero() if not me then return end
	local ID = me.classId if ID ~= myId then Close() end
	
	if spaceformove then
		movetomouse = 0x20
	else
		movetomouse = custommove
	end
 	
	if victim and victim.visible then 
		if not victimText.visible then
			victimText.entity = victim
			victimText.entityPosition = Vector(0,0,victim.healthbarOffset)
			victimText.visible = true
		end
	else
		victimText.visible = false
	end
	
	local attackRange = me.attackRange	
	-- if IsKeyDown(custommove) and SleepCheck("asd") then
		-- local ab = me:FindSpell("ember_spirit_activate_fire_remnant")
		-- me:CastAbility(ab)
		-- Sleep(500,"asd")
	-- end
	if IsKeyDown(movetomouse) and not client.chat then	
		if Animations.CanMove(me) or not start or (victim and GetDistance2D(victim,me) > attackRange+50) then
			start = true
			local lowestHP = targetFind:GetLowestEHP(3000, phys)
			if lowestHP and (not victim or victim.creep or GetDistance2D(me,victim) > 600 or not victim.alive or lowestHP.health < victim.health) and SleepCheck("victim") then			
				victim = lowestHP
				Sleep(250,"victim")
			end
			if victim and GetDistance2D(victim,me) > attackRange+200 and victim.visible then
				local closest = targetFind:GetClosestToMouse(me,2000)
				if closest and (not victim or closest.handle ~= victim.handle) then 
					victim = closest
				end
			end
			if not victim or not victim.hero then 					
				local creeps = entityList:GetEntities(function (v) return (v.courier or (v.creep and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Neutral and v.spawned) or v.classId == CDOTA_BaseNPC_Tower or v.classId == CDOTA_BaseNPC_Venomancer_PlagueWard or v.classId == CDOTA_BaseNPC_Warlock_Golem or (v.classId == CDOTA_BaseNPC_Creep_Lane and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Siege and v.spawned) or v.classId == CDOTA_Unit_VisageFamiliar or v.classId == CDOTA_Unit_Undying_Zombie or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_Unit_Broodmother_Spiderling or v.classId == CDOTA_Unit_Hero_Beastmaster_Boar or v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_BaseNPC_Creep) and v.team ~= me.team and v.alive and v.health > 0 and me:GetDistance2D(v) <= attackRange*2 + 50 end)
				if creeps and #creeps > 0 then
					table.sort(creeps, function (a,b) return a.health < b.health end)
					if creeps[1] and (not victim or victim.handle ~= creeps[1]) then
						victim = creeps[1]	
					end
				end
			end
		end
		if not Animations.CanMove(me) and victim and GetDistance2D(me,victim) <= 2000 then
			if tick > attack and SleepCheck("casting") then
				if victim.hero and not Animations.isAttacking(me) then
					if ID == CDOTA_Unit_Hero_StormSpirit then
						local R = me:GetAbility(4) 
						local W = me:GetAbility(2)
						local Overload = me:DoesHaveModifier("modifier_storm_spirit_overload")
						local Orchid = me:FindItem("item_orchid")
						local Sheep = me:FindItem("item_sheepstick")
						local distance = GetDistance2D(victim,me)
						local orchided = victim:DoesHaveModifier("modifier_item_orchid")
						local disabled = victim:DoesHaveModifier("modifier_sheepstick_debuff") or victim:DoesHaveModifier("modifier_lion_voodoo_restoration") or victim:DoesHaveModifier("modifier_shadow_shaman_voodoo_restoration") or victim:IsStunned()
						local balling = me:DoesHaveModifier("modifier_storm_spirit_ball_lightning")
						if R and R:CanBeCasted() and me:CanCast() and distance > attackRange and not balling and not R.abilityPhase then
							local CP = R:FindCastPoint()
							local delay = CP*1000+client.latency+me:GetTurnTime(victim)*1000
							local speed = R:GetSpecialData("ball_lightning_move_speed", R.level)
							local xyz = SkillShot.SkillShotXYZ(me,victim,delay,speed)
							if xyz then
								me:CastAbility(R,xyz)
								Sleep(CP*1000+me:GetTurnTime(victim)*1000, "casting")
							end
						end
						if Sheep and Sheep:CanBeCasted() and not disabled then
							me:CastAbility(Sheep, victim)
							Sleep(me:GetTurnTime(victim)*1000, "casting")
						end
						if Orchid and Orchid:CanBeCasted() and me:CanCast() and not orchided then
							me:CastAbility(Orchid, victim)
							Sleep(me:GetTurnTime(victim)*1000, "casting")
						end
						if not Overload then
							if W and W:CanBeCasted() and me:CanCast() and not disabled and distance <= W.castRange+200 then
								me:CastAbility(W,victim)
								Sleep(W:FindCastPoint()*1000+me:GetTurnTime(victim)*1000,"casting")
								return
							end
						end
					elseif ID == CDOTA_Unit_Hero_EmberSpirit then
						local R = me:GetAbility(4) 
						local Q = me:GetAbility(1)
						local W = me:GetAbility(2)
						local E = me:GetAbility(3)
						local distance = GetDistance2D(victim,me)
						
						-- if R and R:CanBeCasted() and me:CanCast() and ((distance > W.castRange+300 and W:CanBeCasted()) or (distance > me.attackRange+200)) and not R.abilityPhase then
							-- local CP = R:FindCastPoint()
							-- local delay = CP*1000+client.latency+me:GetTurnTime(victim)*1000
							-- local speed = R:GetSpecialData("ball_lightning_move_speed", R.level)
							-- local xyz = SkillShot.SkillShotXYZ(me,victim,delay,speed)
							-- if xyz then
								-- me:CastAbility(R,xyz)
								-- Sleep(CP*1000+me:GetTurnTime(victim)*1000, "casting")
							-- end
						-- end
						
						if W and W:CanBeCasted() and me:CanCast() then
							local radius = W:GetSpecialData("radius", W.level)/2
							local range = W.castRange+300
							local pred = SkillShot.PredictedXYZ(victim,me:GetTurnTime(victim)*1000+client.latency+200)
							local xyz = pred
							distance = GetDistance2D(me,pred)
							if distance <= range+radius then
								if distance > range then
									xyz = (pred - me.position) * (range-radius) / distance + me.position
								end
								if xyz and me:GetTurnTime(victim) == 0 then
									me:CastAbility(W,xyz)
									-- if Q and Q:CanBeCasted() and me:CanCast() then
										-- local creeps = entityList:GetEntities(function (v) return (v.courier or (v.creep and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Neutral and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Lane and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Siege and v.spawned) or v.classId == CDOTA_Unit_VisageFamiliar or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_Unit_Broodmother_Spiderling or v.classId == CDOTA_Unit_Hero_Beastmaster_Boar or v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_BaseNPC_Creep) and v.team ~= me.team and v.alive and v.health > 0 and victim:GetDistance2D(v) <= 425 end)
										-- if (not creeps or #creeps < 2) then
											-- me:CastAbility(Q)
										-- end
									-- end	
									-- Sleep(me:GetTurnTime(victim)*1000+client.latency+200,"casting")
								end
							end
						end
						if Q and Q:CanBeCasted() and me:CanCast() then
							local creeps = entityList:GetEntities(function (v) return (v.courier or (v.creep and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Neutral and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Lane and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Siege and v.spawned) or v.classId == CDOTA_Unit_VisageFamiliar or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_Unit_Broodmother_Spiderling or v.classId == CDOTA_Unit_Hero_Beastmaster_Boar or v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_BaseNPC_Creep) and v.team ~= me.team and v.alive and v.health > 0 and me:GetDistance2D(v) <= 425 end)
							if (not creeps or #creeps < 2) and distance <= 410 then
								me:CastAbility(Q)
								Sleep(client.latency, "casting")
								return
							end
						end						
					end
				end
				me:Attack(victim)
				attack = tick + 100
			end
		elseif tick > move and SleepCheck("casting") then
			if victim and victim.hero and not Animations.isAttacking(me) then
				if ID == CDOTA_Unit_Hero_StormSpirit then
					local Q = me:GetAbility(1)
					local Overload = me:DoesHaveModifier("modifier_storm_spirit_overload")
					local Dagon = me:FindDagon()
					local distance = GetDistance2D(victim,me)					
					
					if Dagon and Dagon:CanBeCasted() and me:CanCast() then
						me:CastAbility(Dagon, victim)
						Sleep(me:GetTurnTime(victim)*1000, "casting")
					end
					if not Overload then
						if Q and Q:CanBeCasted() and me:CanCast() and distance < attackRange then
							me:CastAbility(Q)
							Sleep(client.latency,"casting")
						end
					end
				elseif ID == CDOTA_Unit_Hero_EmberSpirit then
					local R = me:GetAbility(4) 
					local Q = me:GetAbility(1)
					local W = me:GetAbility(2)
					local E = me:GetAbility(3)
					local distance = GetDistance2D(victim,me)
					

					if E and E:CanBeCasted() and me:CanCast() and distance < 410 then
						me:CastAbility(E)
					end							
				end
			end
			if victim then
				if victim.visible then
					local xyz = SkillShot.PredictedXYZ(victim,me:GetTurnTime(victim)*1000+client.latency+500)
					me:Move(xyz)
				else
					me:Follow(victim)
				end
			else
				me:Move(client.mousePosition)
			end
			move = tick + 100
			start = false
		end
	elseif victim then
		if not resettime then
			resettime = client.gameTime
		elseif (client.gameTime - resettime) >= 6 then
			victim = nil		
		end
		start = false
	end 
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or (me.classId ~= CDOTA_Unit_Hero_StormSpirit and me.classId ~= CDOTA_Unit_Hero_EmberSpirit) then 
			script:Disable()
		else
			reg = true
			victim = nil
			start = false
			myId = me.classId
			sleep = 0 
			resettime = nil
			script:RegisterEvent(EVENT_FRAME, Main)
			script:UnregisterEvent(Load)
		end
	end	
end

function Close()
	victim = nil
	myId = nil
	start = false
	resettime = nil
	
	if reg then
		script:UnregisterEvent(Main)
		script:RegisterEvent(EVENT_TICK, Load)	
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)
