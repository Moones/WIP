require("libs.Res")
require("libs.ScriptConfig")
require("libs.ScreenPosition")
require("libs.AbilityDamage")
require("libs.Animations")

local sPos
if math.floor(client.screenRatio*100) == 133 then
	sPos = ScreenPosition.new(1024, 768, client.screenRatio)
elseif math.floor(client.screenRatio*100) == 166 then
	sPos = ScreenPosition.new(1280, 768, client.screenRatio)
elseif math.floor(client.screenRatio*100) == 177 then
	sPos = ScreenPosition.new(1600, 900, client.screenRatio)
elseif math.floor(client.screenRatio*100) == 160 then
	sPos = ScreenPosition.new(1280, 800, client.screenRatio)
elseif math.floor(client.screenRatio*100) == 125 then
	sPos = ScreenPosition.new(1280, 1024, client.screenRatio)
else
	sPos = ScreenPosition.new(1600, 900, client.screenRatio)
end

config = ScriptConfig.new()
config:Load()

local showDamage = {} local sleeptick = 0
local monitor = client.screenSize.x/1600
local F13 = drawMgr:CreateFont("F13","Tahoma",13*monitor,650*monitor)

function Tick(tick)
	if not PlayingGame() or client.console or tick < sleeptick or not SleepCheck() then return end sleeptick = tick + 200	
	
	local me = entityList:GetMyHero()
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, team = me:GetEnemyTeam()})	
	
	for i = 1, #enemies do
		local v = enemies[i]
		if not v:IsIllusion() then
			local hand = v.handle
			local offset = v.healthbarOffset if offset == -1 then return end						
			
			local abilities = me.abilities
			local totalDamage = 0
			
			for i,k in pairs(abilities) do
				local damage = AbilityDamage.GetDamage(k)
				if k.level > 0 and k:CanBeCasted() and damage and damage > 0 then
					local dmgType = k.dmgType
					local type
					if dmgType == 1 then
						type = DAMAGE_PHYS
					elseif dmgType == 2 then
						type = DAMAGE_MAGC
					elseif dmgType == 4 then
						type = DAMAGE_PURE
					end
					--print(k.dmgType)
					--print(v:DamageTaken(damage,type,me),k.name)
					totalDamage = totalDamage + math.ceil(v:DamageTaken(damage,type,me) - ((v.healthRegen)*(k:FindCastPoint() + k:GetChannelTime(k.level) + client.latency/1000)))
					--print(k.name,math.ceil(v:DamageTaken(damage,type,me) - ((v.healthRegen)*(k:FindCastPoint() + k:GetChannelTime(k.level) + client.latency/1000))))
				end
				if damage and damage > 0 and (k.abilityPhase or (v:DoesHaveModifier("modifier_"..k.name) and me:DoesHaveModifier("modifier_"..k.name) and k.cd > 0) or k.channelTime > 0) then sleeptick = tick + k:FindCastPoint()*2000 + k:GetChannelTime(k.level)*1000 + client.latency break end
			end
			
			local x,y,w,h
			if math.floor(client.screenRatio*100) == 133 then
				x,y,w,h = sPos:GetPosition(37, 14, 72, 27)
			elseif math.floor(client.screenRatio*100) == 166 then
				x,y,w,h = sPos:GetPosition(36, 14, 70, 27)
			elseif math.floor(client.screenRatio*100) == 177 then
				x,y,w,h = sPos:GetPosition(43, 28, 88, 27)
			elseif math.floor(client.screenRatio*100) == 160 then
				x,y,w,h = sPos:GetPosition(38, 15, 74, 27)
			elseif math.floor(client.screenRatio*100) == 125 then
				x,y,w,h = sPos:GetPosition(48, 21, 97, 27)
			else
				x,y,w,h = sPos:GetPosition(42, 18, 83, 27)
			end
			
			if not showDamage[hand] then showDamage[hand] = {}
				showDamage[hand].HPLeft = drawMgr:CreateRect(-x,-y+1,0,10,0x000000FF) showDamage[hand].HPLeft.visible = false showDamage[hand].HPLeft.entity = v showDamage[hand].HPLeft.entityPosition = Vector(0,0,offset)
				showDamage[hand].Hits = drawMgr:CreateText(-x,-y+15, 0xFFFFFF99, "",F13) showDamage[hand].Hits.visible = false showDamage[hand].Hits.entity = v showDamage[hand].Hits.entityPosition = Vector(0,0,offset)					
			end
		
			local hpleft = math.max(v.health - totalDamage, 0)
			--print(totalDamage)
			if v.visible and v.alive and totalDamage > 0 then
				local HPLeftPercent = hpleft/v.maxHealth
				local hitDamage = v:DamageTaken(((me.dmgMin + me.dmgMax)/2 + me.dmgBonus),DAMAGE_PHYS,me)
				local hits = math.ceil(hpleft/hitDamage)
				if Animations.table[me.handle] and Animations.table[me.handle].moveTime then
					hits = math.ceil((hpleft + ((v.healthRegen)*((Animations.GetAttackTime(me) + Animations.table[me.handle].moveTime)*hits)))/hitDamage)
				end
				showDamage[hand].HPLeft.visible = true showDamage[hand].HPLeft.w = w*HPLeftPercent
				if hits > 0 then
					showDamage[hand].Hits.visible = true showDamage[hand].Hits.text = hits.." Hits" showDamage[hand].Hits.color = 0xFFFFFF99
				else
					showDamage[hand].Hits.visible = true showDamage[hand].Hits.text = "Killable" showDamage[hand].Hits.color = 0xFF0000FF
				end
			elseif showDamage[hand].HPLeft.visible then
				showDamage[hand].HPLeft.visible = false
				showDamage[hand].Hits.visible = false
			end
		end
	end
end
	
function GameClose()
	sleeptick = 0
	showDamage = {}
	collectgarbage("collect")
end

script:RegisterEvent(EVENT_CLOSE, GameClose)
script:RegisterEvent(EVENT_TICK, Tick)
