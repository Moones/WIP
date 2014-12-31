require("libs.ScriptConfig")
require("libs.Utils")
require("libs.TargetFind")
require("libs.Animations")
require("libs.EasyHUD")

--[[
        +-------------------------------------------------+              
        |                                                 |          
        |       Broodmother Script - Made by Moones       |        
        |       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^       |     
        +-------------------------------------------------+    
                                                                       
        =+=+=+=+=+=+=+=+=+ VERSION 0.1 +=+=+=+=+=+=+=+=+=+=
	 
        Description:
        ------------
			
		- Auto key assig for spiderlings: Press 1 to select all spiderlings, 2 to select first half of them and 3 to select second half of them.
		- Auto spiderlings chase. Press N and all spiderlings will chase best target to kill.
		- Auto Combo. Will OrbWwalk with your hero and use abilities(Orchid, Q, Dagon) when possible. Will also order all spiderlings to chase the target.
	   
        Changelog:
        ----------
		
		0.2 - Added GUI
		
		0.1 - Working version without GUI(Will be added in next version)

]]--

local config = ScriptConfig.new()
config:SetParameter("ComboKey", "H", config.TYPE_HOTKEY)
config:SetParameter("SpiderChase", "V", config.TYPE_HOTKEY)
config:SetParameter("Menu", "B", config.TYPE_HOTKEY)
config:SetParameter("SelectallSpiders", 49, config.TYPE_HOTKEY)
config:SetParameter("Group1", 50, config.TYPE_HOTKEY)
config:SetParameter("Group2", 51, config.TYPE_HOTKEY)
--config:SetParameter("Group3", 52, config.TYPE_HOTKEY)
config:Load()
	
combokey = config.ComboKey
spiderchase = config.SpiderChase
menu = config.Menu
selectallspiders = config.SelectallSpiders
g1 = config.Group1
g2 = config.Group2
--g3 = config.Group3

local reg = false local victim = nil local myId = nil local attack = 0 local move = 0 local start = false local g1Table = {} local g2Table = {} --local g3Table = {}
local sChase = false local svictim = nil local fogtime = nil local active = true local orchidfirst = false local monitor = client.screenSize.x/1920

local HUD = EasyHUD.new(680*monitor,820*monitor,630,60,"Broodmother Script",90,-1,true,true)
HUD:AddText(5*monitor,5*monitor,'Combo: "'..string.char(combokey)..'" Spiderlings chase: "'..string.char(spiderchase)..'"')
HUD:AddText(5*monitor,20*monitor,"SETTINGS:")
HUD:AddText(430*monitor,5*monitor,"Press " .. string.char(menu) .. " to Open / Close GUI")
local activeCheck = HUD:AddCheckbox(5*monitor,40*monitor,25*monitor,15*monitor,"Enable Script",nil,true);
local orchidCheck = HUD:AddCheckbox(100*monitor,40*monitor,25*monitor,15*monitor,"Use Orchid before first attack",nil,false);
HUD:AddText(260*monitor,20*monitor,"CHASE STATUS:")
local vId,victimText = HUD:AddText(260*monitor,38*monitor,"You: no chase")
local sId,svictimText = HUD:AddText(430*monitor,38*monitor,"Spiders: no chase")
HUD:Close()

function Key(msg, code)
	if msg ~= KEY_UP or client.chat or client.console then return end
	if code == selectallspiders then 
		local player = entityList:GetMyPlayer()
		local me = entityList:GetMyHero()
		local Spiderlings = entityList:GetEntities({classId=CDOTA_Unit_Broodmother_Spiderling, controllable=true, team=me.team, alive=true})
		for i,v in pairs(player.selection) do player:Unselect(v) end
		for i,v in pairs(Spiderlings) do player:SelectAdd(v) end 
		return true
	elseif code == g1 then
		local player = entityList:GetMyPlayer()
		local me = entityList:GetMyHero()
		local Spiderlings = entityList:GetEntities({classId=CDOTA_Unit_Broodmother_Spiderling, controllable=true, team=me.team, alive=true})
		for i,v in pairs(player.selection) do player:Unselect(v) end
		for i,v in pairs(Spiderlings) do if i < #Spiderlings/2 then player:SelectAdd(v) end end
		return true
	elseif code == g2 then
		local player = entityList:GetMyPlayer()
		local me = entityList:GetMyHero()
		local Spiderlings = entityList:GetEntities({classId=CDOTA_Unit_Broodmother_Spiderling, controllable=true, team=me.team, alive=true})
		for i,v in pairs(player.selection) do player:Unselect(v) end
		for i,v in pairs(Spiderlings) do if i > #Spiderlings/2 then player:SelectAdd(v) end end
		return true
	elseif code == spiderchase then
		sChase = not sChase
		return true
	elseif code == menu then
		if HUD then
			if HUD:IsClosed() then
				HUD:Open()
			else
				HUD:Close()
			end
		end
	end
end

function Main(tick)
	if not PlayingGame() or client.paused then return end
	local me = entityList:GetMyHero()
	local ID = me.classId if ID ~= myId then Close() end
	local player = entityList:GetMyPlayer()

	if HUD:IsChecked(6) then
		active = true
	else
		active = false
	end
	
	if HUD:IsChecked(7) then
		orchidfirst = true
	else
		orchidfirst = false
	end
	
	if active then
		local Spiderlings = entityList:GetEntities({classId=CDOTA_Unit_Broodmother_Spiderling, controllable=true, team=me.team, alive=true})
		if sChase and #Spiderlings > 0 then
			local enemy = targetFind:GetLowestEHP(3000, phys)
			if (not svictim and enemy) or (svictim and svictim.visible and enemy) then
				svictim = enemy
			elseif victim and not svictim.alive then
				svictim = nil
				sChase = false
				return
			end
			if svictim and svictim.alive and SleepCheck("chase") then
				local prev = player.selection
				for i,v in pairs(player.selection) do player:Unselect(v) end
				for i,v in pairs(Spiderlings) do
					if SleepCheck(v.handle) then
						player:SelectAdd(v)
					end
				end
				svictimText.text = "Spiders: chasing "..client:Localize(svictim.name)
				svictimText.color = 0x17E317FF
				player:Attack(svictim)
				SelectBack(prev)
				Sleep(500, "chase")
			end
			if not svictim.visible then
				if not fogtime then
					fogtime = client.gameTime
				elseif (client.gameTime - fogtime) >= 10 then
					svictim = nil
					sChase = false
					fogtime = nil
					return
				end
			elseif fogtime then
				fogtime = nil
			end				
		else
			if svictim then
				svictim = nil
			end
			svictimText.text = "Spiders: no chase"
			svictimText.color = -1
		end
				
		if IsKeyDown(combokey) and not client.chat then	
			local Orchid = me:FindItem("item_orchid")
			local Dagon = me:FindDagon()
			local Q = me:GetAbility(1)
			if Animations.CanMove(me) or not start then
				start = true
				local lowestHP = targetFind:GetLowestEHP(3000, phys)
				if lowestHP and (not victim or victim.creep or GetDistance2D(me,victim) > 600 or not victim.alive or lowestHP.health < victim.health) and SleepCheck("victim") then			
					victim = lowestHP
					Sleep(250,"victim")
				end
				if not victim or not victim.hero then 					
					local creeps = entityList:GetEntities(function (v) return (v.courier or (v.creep and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Neutral and v.spawned) or v.classId == CDOTA_BaseNPC_Tower or v.classId == CDOTA_BaseNPC_Venomancer_PlagueWard or v.classId == CDOTA_BaseNPC_Warlock_Golem or (v.classId == CDOTA_BaseNPC_Creep_Lane and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Siege and v.spawned) or v.classId == CDOTA_Unit_VisageFamiliar or v.classId == CDOTA_Unit_Undying_Zombie or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_Unit_Broodmother_Spiderling or v.classId == CDOTA_Unit_Hero_Beastmaster_Boar or v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_BaseNPC_Creep) and v.team ~= me.team and v.alive and v.health > 0 and me:GetDistance2D(v) <= me.attackRange*2 + 50 end)
					table.sort(creeps, function (a,b) return a.health < b.health end)
					victim = creeps[1]					
				end
			end
			if victim then
				victimText.text = "You: chasing "..client:Localize(victim.name)
				victimText.color = 0x17E317FF
			end
			if SleepCheck("combo") and not Animations.CanMove(me) and victim and GetDistance2D(me,victim) <= 2000 then
				if tick > attack then
					if Orchid and Orchid:CanBeCasted() and orchidfirst and GetDistance2D(me,victim) <= Orchid.castRange+50 then
						me:CastAbility(Orchid, victim)
						Sleep(client.latency+me:GetTurnTime(victim)*1000, "combo")
						return
					end
					me:Attack(victim)			
					attack = tick + 100
					if not sChase and #Spiderlings > 0 then
						sChase = true
						svictim = victim
					end
				end
			elseif tick > move then
				if SleepCheck("combo") then
					if victim then
						if Orchid and Orchid:CanBeCasted() then
							me:CastAbility(Orchid, victim)
							Sleep(client.latency+me:GetTurnTime(victim)*1000, "combo")
							return
						end
						if Q and Q:CanBeCasted() then
							me:CastAbility(Q, victim)
							Sleep(Q:FindCastPoint()*1000+client.latency+me:GetTurnTime(victim)*1000, "combo")
							return
						end
						if Dagon and Dagon:CanBeCasted() then
							me:CastAbility(Dagon, victim)
							Sleep(client.latency+me:GetTurnTime(victim)*1000, "combo")
							return
						end
					end
					me:Move(client.mousePosition)
					move = tick + 100
					start = false
				end
			end
		else
			if victim then
				victim = nil
				start = false
			end
			victimText.color = -1
			victimText.text = "You: no chase"
		end 
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Broodmother then 
			script:Disable()
		else
			reg = true
			victim = nil
			start = false
			sChase = false
			myId = me.classId
			svictim = nil
			fogtime = nil
			active = true
			orchidfirst = false
			
			if HUD then
				HUD:Open()	
			end
			
			g1Table = {} g2Table = {} --g3Table = {}
			script:RegisterEvent(EVENT_FRAME, Main)
			script:RegisterEvent(EVENT_KEY, Key)
			script:UnregisterEvent(Load)
		end
	end	
end

function Close()
	victim = nil
	myId = nil
	start = false	
	sChase = false
	svictim = nil
	fogtime = nil
	active = true
	orchidfirst = false
	g1Table = {} g2Table = {} --g3Table = {}
	
	if HUD then
		HUD:Close()	
	end
	
	if reg then
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK, Load)	
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)
