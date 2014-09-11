local F13 = drawMgr:CreateFont("F13","Tahoma",13,550)
local info = {}

local sleeptick = 0

if math.floor(client.screenRatio*100) == 177 then
testX = 1600
tinfoHeroSize = 55
tinfoHeroDown = 17.714
txxB = 2.527
txxG = 3.47
elseif math.floor(client.screenRatio*100) == 166 then
testX = 1280
tinfoHeroSize = 47
tinfoHeroDown = 17.714
txxB = 2.558
txxG = 3.62
elseif math.floor(client.screenRatio*100) == 160 then
testX = 1280
tinfoHeroSize = 48.5
tinfoHeroDown = 17.714
txxB = 2.579
txxG = 3.735
elseif math.floor(client.screenRatio*100) == 133 then
testX = 1024
tinfoHeroSize = 47
tinfoHeroDown = 17.714
txxB = 2.747
txxG = 4.54
elseif math.floor(client.screenRatio*100) == 125 then
testX = 1280
tinfoHeroSize = 58
tinfoHeroDown = 17.714
tinfoHeroSS = 23
txxB = 2.747
txxG = 4.54
else
testX = 1600
tinfoHeroSize = 55
tinfoHeroDown = 17.714
tinfoHeroSS = 22
txxB = 2.527
txxG = 3.47
end

local x_ = tinfoHeroSize*(client.screenSize.x/testX)
local y_ = client.screenSize.y/tinfoHeroDown
local monitor = client.screenSize.x/1600

local click = {}

function Tick(tick)

	if not client.connected or client.loading or client.console or tick < sleeptick then return end

	sleeptick = tick + 200

	local me = entityList:GetMyHero()

	if not me then return end

	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, team=me:GetEnemyTeam()})
	--local player = entityList:GetEntities({classId=CDOTA_PlayerResource})[1]

	for i,v in ipairs(enemies) do        
    	local xx = GetXX(v)
		if not click[v.playerId] then click[v.playerId] = drawMgr:CreateRect(xx-20+x_*v.playerId,0,x_,35*monitor,0x0000000) end
	end
end

function Key(msg,code)
	if client.chat then return end
	local me = entityList:GetMyHero()
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, team=me:GetEnemyTeam()})
	for i,v in ipairs(enemies) do 
		local xx = GetXX(v)
		if IsMouseOnButton(xx-20+x_*v.playerId,0,x_,35*monitor) then
			if msg == LBUTTON_DOWN then
				SelectUnit(v)
				return true
			end
		end
	end
end

function GetXX(ent)
	local team = ent.team
	if team == 2 then		
		return client.screenSize.x/txxG + 1
	elseif team == 3 then
		return client.screenSize.x/txxB 
	end
end

function IsMouseOnButton(x,y,h,w)
	local mx = client.mouseScreenPosition.x
	local my = client.mouseScreenPosition.y
	return mx > x and mx <= x + w and my > y and my <= y + h
end
	
function GameClose()
	click = {}
	collectgarbage("collect")
end

script:RegisterEvent(EVENT_CLOSE, GameClose)
script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_KEY,Key)
