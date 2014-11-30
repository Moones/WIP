require("libs.ScriptConfig")
require("libs.Utils")
require("libs.SideMessage")
require("libs.HeroInfo")
require("libs.EasyHUD")
require("libs.Animations")
require("libs.Lasthit")

local config = ScriptConfig.new()
config:SetParameter("CustomMove", "G", config.TYPE_HOTKEY)
config:SetParameter("Menu", "H", config.TYPE_HOTKEY)
config:SetParameter("Spaceformove", true)
config:SetParameter("enableLasthits", true)
config:SetParameter("enableDenies", true)
config:SetParameter("AutoUnAggro", true)
config:SetParameter("ActiveFromStart", true)
config:SetParameter("UseAttackModifiers", true)
config:SetParameter("ShowMenuAtStart", true)
config:SetParameter("ShowSign", true)
config:Load()
	
custommove = config.CustomMove
menu = config.Menu
spaceformove = config.Spaceformove
enablelasthits = config.enableLasthits
enabledenies = config.enableDenies
autounaggro = config.AutoUnAggro
active = config.ActiveFromStart
attackmodifiers = config.UseAttackModifiers
showmenu = config.ShowMenuAtStart
showsign = config.ShowSign

local reg = false local HUD = nil local myId = nil local geminate_attack = 0 local myhero = nil local move = 0 local attack = 0 local stop = 0 local sleepaggro = 0

local monitor = client.screenSize.x/1600
local F15 = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText = drawMgr:CreateText(10*monitor,600*monitor,-1,"AdvancedCreepControl: Press " .. string.char(menu) .. " to open Menu",F14) statusText.visible = false

function activeCheck()	
	if PlayingGame() then
		if not active then
			active = true
			GenerateSideMessage(entityList:GetMyHero().name,"     Advanced CreepControl is ON!")
		else
			active = false
			GenerateSideMessage(entityList:GetMyHero().name,"    Advanced CreepControl is OFF!")
		end
	end
end

function lhCheck()
	if PlayingGame() then
		if not enablelasthits then
			enablelasthits = true
			GenerateSideMessage(entityList:GetMyHero().name,"             Lasthitting is ON!")
		else 
			enablelasthits = nil
			GenerateSideMessage(entityList:GetMyHero().name,"            Lasthitting is OFF!")
		end
	end
end

function dCheck()
	if PlayingGame() then
		if not enabledenies then
			enabledenies = true
			GenerateSideMessage(entityList:GetMyHero().name,"                Denying is ON!")
		else
			enabledenies = nil
			GenerateSideMessage(entityList:GetMyHero().name,"               Denying is OFF!")
		end
	end
end

function aCheck()
	if PlayingGame() then
		if not autounaggro then
			autounaggro = true
			GenerateSideMessage(entityList:GetMyHero().name,"            AutoUnAggro is ON!")
		else
			autounaggro = nil
			GenerateSideMessage(entityList:GetMyHero().name,"           AutoUnAggro is OFF!")
		end
	end
end

function mCheck()
	if PlayingGame() then
		if not attackmodifiers then
			attackmodifiers = true
			GenerateSideMessage(entityList:GetMyHero().name,"    Using AttackModifiers is ON!")
		else
			attackmodifiers = nil
			GenerateSideMessage(entityList:GetMyHero().name,"   Using AttackModifiers is OFF!")
		end
	end
end

function smCheck()
	if PlayingGame() then
		if not showmenu then
			showmenu = true
			GenerateSideMessage(entityList:GetMyHero().name,"      Show Menu on Start is ON!")
		else
			showmenu = nil
			GenerateSideMessage(entityList:GetMyHero().name,"     Show Menu on Start is OFF!")
		end
	end
end

function ssCheck()
	if PlayingGame() then
		if not showsign then
			showsign = true
			GenerateSideMessage(entityList:GetMyHero().name,"     You will now see the Sign!")
		else
			showsign = false
			GenerateSideMessage(entityList:GetMyHero().name," You will not see the Sign now!")
		end
	end
end

function Key(msg, code)
	if msg ~= KEY_UP or client.chat or client.console then return end
	if code == menu and HUD then 
		if HUD:IsClosed() then
			HUD:Open()
			statusText.visible = false
		else
			HUD:Close()
			if showsign then
				statusText.visible = true
			end
		end
	end
end

function Main(tick)
	if not PlayingGame() or Animations.maxCount <= 0 then return end	
	local me = entityList:GetMyHero() 
	local ID = me.classId if ID ~= myId then Close() end
		
	if spaceformove then
		movetomouse = 0x20
	else
		movetomouse = custommove
	end
	
	if not HUD then 
		CreateHUD()
		if not showmenu then
			HUD:Close()
		end
	end

	if HUD and HUD:IsClosed() and showsign then
		statusText.visible = true
	end
	
	if not myhero then
		myhero = Hero(me)
	else
		myhero:Update()
		if active and not me:IsChanneling() then
			local canmove = Animations.CanMove(me)
			if IsKeyDown(movetomouse) and not client.chat then	
				Lasthit.GetLasthit(me)
				if Lasthit.table[me.handle] and Lasthit.table[me.handle].alive then
					if tick > stop then
						StopAttack(me,Lasthit.table[me.handle],Lasthit.table[me.handle].class)
						stop = tick + 100
					end
					if tick > attack then
						Hit(me,Lasthit.table[me.handle])
						attack = tick + 100
					end
				else
					if tick > move then
						me:Move(client.mousePosition)
						move = tick + 100
					end
				end
			end
			-- for i,v in ipairs(entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true,team=me:GetEnemyTeam()})) do
				-- print((math.max(math.abs(FindAngleR(me) - math.rad(FindAngleBetween(me, v))), 0)))
			-- end
			if autounaggro then		
				for i,v in ipairs(entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane})) do				
					for k,z in ipairs(entityList:GetProjectiles({target=me})) do
						if z.source then
							if z.source.classId == CDOTA_BaseNPC_Creep_Lane or z.source.classId == CDOTA_BaseNPC_Tower then
								if canmove and v.team == me.team and v.visible and v.alive and tick > sleepaggro and v.health > (v.health/100)*5 and GetDistance2D(z.source,me) <= z.source.attackRange + 300 then								
									if (myhero.isRanged and GetDistance2D(v,me) < myhero.attackRange) or (not myhero.isRanged and GetDistance2D(v,me) < myhero.attackRange + 200) then								
										entityList:GetMyPlayer():Attack(v)
										me:Move(client.mousePosition)		
										sleepaggro = tick + 200										
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

class 'Hero'

function Hero:__init(heroEntity)

	self.heroEntity = heroEntity

	local name = heroEntity.name

	if not heroInfo[name] then
		return nil
	end

	if not heroInfo[name].projectileSpeed then
		self.isRanged = false
	else
		self.isRanged = true
	end
end

function Hero:Update()
	if Animations.maxCount and Animations.maxCount > 0 then
		self.attackRange = Lasthit.AttackRange(self.heroEntity)
	end
end

function GenerateSideMessage(heroname,msg)
	local sidemsg = sideMessage:CreateMessage(300*monitor,60*monitor,0x111111C0,0x444444FF,150,1000)
	sidemsg:AddElement(drawMgr:CreateRect(10*monitor,10*monitor,72*monitor,40*monitor,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroname:gsub("npc_dota_hero_",""))))
	sidemsg:AddElement(drawMgr:CreateText(85*monitor,20*monitor,-1,"" .. msg,F15))
end

function CreateHUD()
	if not HUD then
		HUD = EasyHUD.new(550*monitor,300*monitor,500*monitor,300*monitor,"AdvancedCreepControl",0x111111C0,-1,true,true)
		HUD:AddText(5*monitor,10*monitor,"Hello, this is AdvancedCreepControl Menu and you might want to adjust settings")
		if spaceformove then
			HUD:AddText(5*monitor,30*monitor,"Usage: Hold SPACE for Autolasthit / Autodeny while moving to your mouse position")
		else
			HUD:AddText(5*monitor,30*monitor,"Usage: Hold "..string.char(movetomouse).." for Autolasthit / Autodeny while moving to your mouse position")
		end
		HUD:AddText(300*monitor,270*monitor,"Press " .. string.char(menu) .. " for Open / Close Menu")
		HUD:AddCheckbox(5*monitor,50*monitor,35*monitor,20*monitor,"ENABLE SCRIPT",activeCheck,active)
		HUD:AddText(5*monitor,75*monitor,"Script Settings:")
		HUD:AddCheckbox(5*monitor,95*monitor,35*monitor,20*monitor,"ENABLE AUTO LASTHIT",lhCheck,enablelasthits)
		HUD:AddCheckbox(5*monitor,115*monitor,35*monitor,20*monitor,"ENABLE AUTO DENY",dCheck,enabledenies)
		HUD:AddCheckbox(5*monitor,135*monitor,35*monitor,20*monitor,"ENABLE AUTO UNAGGRO",aCheck,autounaggro)
		HUD:AddCheckbox(5*monitor,155*monitor,35*monitor,20*monitor,"ENABLE ATTACK MODIFIERS",mCheck,attackmodifiers)
		HUD:AddCheckbox(185*monitor,95*monitor,35*monitor,20*monitor,"SHOW MENU ON START",smCheck,showmenu)
		HUD:AddCheckbox(185*monitor,115*monitor,35*monitor,20*monitor,"SHOW SIGN",ssCheck,showsign)
		HUD:AddButton(5*monitor,250*monitor,110*monitor,40*monitor, 0x60615FFF,"Save Settings",SaveSettings)
	end
end

function SaveSettings()
	local file = io.open(SCRIPT_PATH.."/config/AdvancedCreepControl.txt", "w+")
	if file then
		if enabledenies then
			file:write("enableDenies = true \n")
		else
			file:write("enableDenies = false \n")
		end
		if enablelasthits then
			file:write("enableLasthits = true \n")
		else
			file:write("enableLasthits = false \n")
		end
		file:write("CustomMove = "..string.char(custommove).."\n")
		if spaceformove then
			file:write("Spaceformove = true \n")
		else
			file:write("Spaceformove = false \n")
		end
		if autounaggro then
			file:write("AutoUnAggro = true \n")
		else
			file:write("AutoUnAggro = false \n")
		end
		if attackmodifiers then
			file:write("UseAttackModifiers = true \n")
		else
			file:write("UseAttackModifiers = false \n")
		end
		if showmenu then
			file:write("ShowMenuAtStart = true \n")
		else
			file:write("ShowMenuAtStart = false \n")
		end
		if showsign then
			file:write("ShowSign = true \n")
		else
			file:write("ShowSign = false \n")
		end
		if active then
			file:write("ActiveFromStart = true \n")
		else
			file:write("ActiveFromStart = false \n")
		end
		file:write("Menu = "..string.char(menu))
        file:close()
		if PlayingGame() then
			GenerateSideMessage(entityList:GetMyHero().name,"        Settings succesfully saved!")
		end
    end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then 
			script:Disable()
		else
			statusText.visible = false
			myhero = nil
			HUD = nil
			reg = true
			myId = me.classId
			geminate_attack = 0
			move = 0  attack = 0  stop = 0
			if active then
				GenerateSideMessage(entityList:GetMyHero().name,"     Advanced CreepControl is ON!")
			end
			script:RegisterEvent(EVENT_FRAME, Main)
			script:RegisterEvent(EVENT_KEY, Key)
			script:UnregisterEvent(Load)
		end
	end	
end  

function Close()
	statusText.visible = false
	myhero = nil
	myId = nil
	
	SaveSettings()
	
	if HUD then
		HUD:Close()	
		HUD = nil
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
