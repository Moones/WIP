require("libs.ScriptConfig")
require("libs.Utils")

local config = ScriptConfig.new()
config:SetParameter("Meepo1", 49, config.TYPE_HOTKEY) -- 49 is Key Code for 1
config:SetParameter("Meepo2", 50, config.TYPE_HOTKEY) -- 50 is Key Code for 2 for all KeyCodes go to http://www.zynox.net/forum/threads/336-KeyCodes
config:SetParameter("Meepo3", 51, config.TYPE_HOTKEY)
config:SetParameter("Meepo4", 52, config.TYPE_HOTKEY)
config:SetParameter("Meepo5", 53, config.TYPE_HOTKEY)
config:SetParameter("Select", 18, config.TYPE_HOTKEY)
config:SetParameter("UnAggro", 16, config.TYPE_HOTKEY) -- 16 is Key Code for Shift, Holding UnAggro Key + Meepo key will make Meepo to unaggro himself instantly.
config:Load()	

meepo1 = config.Meepo1
meepo2 = config.Meepo2
meepo3 = config.Meepo3
meepo4 = config.Meepo4
meepo5 = config.Meepo5
select = config.Select
unaggro = config.UnAggro

local reg = false
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",25*monitor,600*monitor) 
local meeposigns = {}
local sleep = 0
local meeponumber = 0 

function Main(tick)
	if not PlayingGame() or tick < sleep then return end
	sleep = tick + 100
	local me = entityList:GetMyHero()
	local meepos = entityList:GetEntities({type=LuaEntity.TYPE_MEEPO, team=me.team, alive=true})
	local meepoUlt = me:GetAbility(4)
	for number,meepo in ipairs(meepos) do
		if me.alive then
			meepoUlt = meepo:GetAbility(4)
			meeponumber = (meepoUlt:GetProperty( "CDOTA_Ability_Meepo_DividedWeStand", "m_nWhichDividedWeStand" ) + 1)
			if not meeposigns[meepo.handle] then
				if meeponumber == 1 then
					meeposigns[meepo.handle] = drawMgr:CreateText(-5*monitor,-70*monitor,-1,""..meeponumber,F14)
				else
					meeposigns[meepo.handle] = drawMgr:CreateText(-5*monitor,-60*monitor,-1,""..meeponumber,F14)
				end
			end
			meeposigns[meepo.handle].visible = true
			meeposigns[meepo.handle].entity = meepo
			meeposigns[meepo.handle].entityPosition = Vector(0,0,meepo.healthbarOffset)
		else
			meeposigns[meepo.handle].visible = false
		end
	end		
end

function Key()
	if client.chat or client.console then return end
	local me = entityList:GetMyHero()
	local meepos = entityList:GetEntities({type=LuaEntity.TYPE_MEEPO, team=me.team, alive=true})
	local allies = entityList:GetEntities({type={LuaEntity.TYPE_HERO or LuaEntity.TYPE_MEEPO or LuaEntity.TYPE_CREEP}, team=me.team, alive=true})
	local meepoUlt = me:GetAbility(4)
	for number,meepo in ipairs(meepos) do
		if me.alive then
			meepoUlt = meepo:GetAbility(4)
			meeponumber = (meepoUlt:GetProperty( "CDOTA_Ability_Meepo_DividedWeStand", "m_nWhichDividedWeStand" ) + 1)
			if IsKeyDown(select) then
				if IsKeyDown(meepo1) and meeponumber == 1 then
					SelectUnit(meepo)
					return true
				elseif IsKeyDown(meepo2) and meeponumber == 2 then
					SelectUnit(meepo)
					return true
				elseif IsKeyDown(meepo3) and meeponumber == 3 then
					SelectUnit(meepo)
					return true
				elseif IsKeyDown(meepo4) and meeponumber == 4 then
					SelectUnit(meepo)
					return true
				elseif IsKeyDown(meepo5) and meeponumber == 5 then
					SelectUnit(meepo)
					return true
				end
			elseif IsKeyDown(unaggro) then
				for i,v in ipairs(meepos) do
					if GetDistance2D(meepo, v) < 600 and v.handle ~= meepo.handle then	
						print(v.name)
						if IsKeyDown(meepo1) and meeponumber == 1 then	
							meepo:Attack(v)
							return true
						elseif IsKeyDown(meepo2) and meeponumber == 2 then
							meepo:Attack(v)
							return true
						elseif IsKeyDown(meepo3) and meeponumber == 3 then
							meepo:Attack(v)
							return true
						elseif IsKeyDown(meepo4) and meeponumber == 4 then
							meepo:Attack(v)
							return true
						elseif IsKeyDown(meepo5) and meeponumber == 5 then
							meepo:Attack(v)
							return true
						end
					end
				end
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Meepo then 
			script:Disable()
		else
			meeposigns = {}
			reg = true
			script:RegisterEvent(EVENT_TICK, Main)
			script:RegisterEvent(EVENT_KEY, Key)
			script:UnregisterEvent(Load)
		end
	end	
end

function Close()
	meeposigns = {}
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK, Load)	
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)
