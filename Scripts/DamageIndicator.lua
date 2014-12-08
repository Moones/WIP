--<<Shows how much damage you will deal with your spells+items and how much hits you will need to kill enemy>>
require("libs.ScreenPosition")
require("libs.AbilityDamage")
require("libs.Animations")
require("libs.Utils")

--[[
   _                    _
 _( ) DAMAGE INDICATOR ( )_
(_, |      __ __      / ,,_)
   \'\    /  ^  \    /'/
    '\'\,/\      \,/'/'
      '\| []   [] |/'
        (_  /^\  _)
          \  ~  /
          /#####\
        /'/{^^^}\'\
    _,/'/'  ^^^  '\'\,_
   (_, |    BY     | ,_)
     (_)  MOONES   (_)

        Description:        
        ------------                                 
		 
         - This script shows how much HP will enemy have after casting all your spells/items.
		 - Shows how much hits will you need to kill enemy. 
		 - If you kill enemy just from spells/items it will show you which ones you need to use.
		 
        Changelog:
        ----------
		
]]--

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

local showDamage = {} local killSpellsIcons = {} local killSpells = {} local killItemsIcons = {} local killItems = {} local sleeptick = 0 local onespell = {}
local monitor = client.screenSize.x/1600
local F13 = drawMgr:CreateFont("F13","Tahoma",13*monitor,650*monitor)

function Tick(tick)
	if not PlayingGame() or client.console or tick < sleeptick then return end
	
	local me = entityList:GetMyHero()
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, team = me:GetEnemyTeam()})	
	
	for e = 1, #enemies do
		local v = enemies[e]
		if not v:IsIllusion() then
			local hand = v.handle
			local offset = v.healthbarOffset if offset == -1 then return end						
			
			local abilities = me.abilities
			local items = me.items
			local totalDamage = 0
			local ethMult = nil
			local eth = me:FindItem("item_ethereal_blade")
			
			killSpells[hand] = {}
			killItems[hand] = {}
			
			if eth and eth:CanBeCasted() then
				ethMult = true
			end
			
			for h,k in ipairs(items) do
				local damage = AbilityDamage.GetDamage(k)
				if k:CanBeCasted() and damage and damage > 0 then
					local type = AbilityDamage.itemList[k.name].type
					local takenDmg
					if v.health ~= v.maxHealth then
						takenDmg = math.ceil(v:DamageTaken(damage,type,me) - ((v.healthRegen)*(client.latency/1000)))
					else
						takenDmg = math.ceil(v:DamageTaken(damage,type,me))
					end
					if ethMult and type == DAMAGE_MAGC then
						takenDmg = takenDmg*1.4
					end
					if (v.health - takenDmg) <= 0 then
						if not onespell[hand] or onespell[hand][2] > 0 then
							onespell[hand] = {k, 0, true}
						end
					elseif (v.health - totalDamage) > 0 then
						killItems[hand][#killItems[hand]+1] = k.name
						onespell[hand] = nil
					else 
						if onespell[hand] and onespell[hand][1] == k then
							onespell[hand] = nil
						end
					end
					totalDamage = totalDamage + takenDmg
				end
			end
			
			for h,k in ipairs(abilities) do
				local damage = AbilityDamage.GetDamage(k)
				if k.level > 0 and (k:CanBeCasted() or k.abilityPhase) and damage and damage > 0 then
					local dmgType = k.dmgType
					local type
					if dmgType == 1 then
						type = DAMAGE_PHYS
					elseif dmgType == 2 then
						type = DAMAGE_MAGC
					elseif dmgType == 4 then
						type = DAMAGE_PURE
					end
					if k.name == "lina_laguna_blade" and me:AghanimState() then type = DAMAGE_PURE end	
					local takenDmg
					if v.health ~= v.maxHealth then
						takenDmg = math.ceil(v:DamageTaken(damage,type,me) - ((v.healthRegen)*(k:FindCastPoint() + k:GetChannelTime(k.level) + client.latency/1000)))
					else
						takenDmg = math.ceil(v:DamageTaken(damage,type,me))
					end
					if ethMult and type == DAMAGE_MAGC then
						takenDmg = takenDmg*1.4
					end
					if (v.health - takenDmg) <= 0 then
						if not onespell[hand] or onespell[hand][2] > h then
							onespell[hand] = {k, h}
						end
					elseif (v.health - totalDamage) > 0 then
						killSpells[hand][#killSpells[hand]+1] = k.name
						onespell[hand] = nil
					else 
						if onespell[hand] and onespell[hand][1] == k then
							onespell[hand] = nil
						end
					end
					totalDamage = totalDamage + takenDmg
				end
				if damage and damage > 0 and ((v:DoesHaveModifier("modifier_"..k.name) and me:DoesHaveModifier("modifier_"..k.name) and k.cd > 0) or k.channelTime > 0 or k.abilityPhase) then sleeptick = tick + k:FindCastPoint()*2000 + k:GetChannelTime(k.level)*1000 + client.latency return end
			end
			
			local x,y,w,h
			if math.floor(client.screenRatio*100) == 133 then
				x,y,w,h = sPos:GetPosition(37, 24, 72, 10)
			elseif math.floor(client.screenRatio*100) == 166 then
				x,y,w,h = sPos:GetPosition(37, 23, 71, 7)
			elseif math.floor(client.screenRatio*100) == 177 then
				x,y,w,h = sPos:GetPosition(43, 28, 83.5, 10)
			elseif math.floor(client.screenRatio*100) == 160 then
				x,y,w,h = sPos:GetPosition(37, 25, 74, 8)
			elseif math.floor(client.screenRatio*100) == 125 then
				x,y,w,h = sPos:GetPosition(48, 32, 94, 10)
			else
				x,y,w,h = sPos:GetPosition(43, 28, 83, 10)
			end
			
			if not showDamage[hand] then showDamage[hand] = {}
				showDamage[hand].HPLeft = drawMgr:CreateRect(-x,-y+1,0,h,0x000000FF) showDamage[hand].HPLeft.visible = false showDamage[hand].HPLeft.entity = v showDamage[hand].HPLeft.entityPosition = Vector(0,0,offset)
				showDamage[hand].Hits = drawMgr:CreateText(-x,-y+15, 0xFFFFFF99, "",F13) showDamage[hand].Hits.visible = false showDamage[hand].Hits.entity = v showDamage[hand].Hits.entityPosition = Vector(0,0,offset)					
			end
		
			local hpleft = math.max(v.health - totalDamage, 0)
			if v.visible and v.alive then
				local HPLeftPercent = hpleft/v.maxHealth
				local hitDamage = v:DamageTaken(((me.dmgMin + me.dmgMax)/2 + me.dmgBonus),DAMAGE_PHYS,me)
				local hits = math.ceil(hpleft/hitDamage)
				if Animations.table[me.handle] and Animations.table[me.handle].moveTime then
					hits = math.ceil((hpleft + ((v.healthRegen)*((Animations.table[me.handle].moveTime)*hits)))/hitDamage)
				end
				if totalDamage > 0 then
					showDamage[hand].HPLeft.visible = true showDamage[hand].HPLeft.w = w*HPLeftPercent
				elseif showDamage[hand].HPLeft.visible then
					showDamage[hand].HPLeft.visible = false
				end
				if hits > 0 then
					killSpellsIcons[hand] = {}
					killItemsIcons[hand] = {}
					showDamage[hand].Hits.visible = true showDamage[hand].Hits.text = hits.." Hits" showDamage[hand].Hits.color = 0xFFFFFF99
				else
					killSpellsIcons[hand] = {}
					killItemsIcons[hand] = {}
					showDamage[hand].Hits.visible = true showDamage[hand].Hits.text = "Killable" showDamage[hand].Hits.color = 0xFF0000FF
					if not onespell[hand] then
						if #killSpells[hand] > 0 then					
							for i = 1, #killSpells[hand] do
								local ks = killSpells[hand][i]
								if not killSpellsIcons[hand][i] then
									killSpellsIcons[hand][i] = drawMgr:CreateRect(-x/monitor+30*monitor+(17*monitor*i),-y+15*monitor,15*monitor,16*monitor,0x000000FF) killSpellsIcons[hand][i].textureId = drawMgr:GetTextureId("NyanUI/Spellicons/"..ks) killSpellsIcons[hand][i].entity = v killSpellsIcons[hand][i].entityPosition = Vector(0,0,offset) killSpellsIcons[hand][i].visible = true		 			
								end
							end
						end
						if #killItems[hand] > 0 then	
							for i = 1, #killItems[hand] do
								local ks = killItems[hand][i]
								if not killItemsIcons[hand][i] then
									local yy = 30
									if #killSpells[hand] == 0 then
										yy = 15
									end
									killItemsIcons[hand][i] = drawMgr:CreateRect(-x/monitor+30*monitor+(17*monitor*i),-y+yy*monitor,20*monitor,16*monitor,0x000000FF) killItemsIcons[hand][i].textureId = drawMgr:GetTextureId("NyanUI/items/"..ks:gsub("item_","")) killItemsIcons[hand][i].entity = v killItemsIcons[hand][i].entityPosition = Vector(0,0,offset) killItemsIcons[hand][i].visible = true		 			
								end
							end
						end
					else
						killSpellsIcons[hand] = {}
						if onespell[hand][3] then
							killSpellsIcons[hand][1] = drawMgr:CreateRect(-x/monitor+30*monitor+16*monitor,-y+15*monitor,15*monitor,16*monitor,0x000000FF) killSpellsIcons[hand][1].textureId = drawMgr:GetTextureId("NyanUI/items/"..onespell[hand][1].name:gsub("item_","")) killSpellsIcons[hand][1].entity = v killSpellsIcons[hand][1].entityPosition = Vector(0,0,offset) killSpellsIcons[hand][1].visible = true		 			
						else
							killSpellsIcons[hand][1] = drawMgr:CreateRect(-x/monitor+30*monitor+16*monitor,-y+15*monitor,15*monitor,16*monitor,0x000000FF) killSpellsIcons[hand][1].textureId = drawMgr:GetTextureId("NyanUI/Spellicons/"..onespell[hand][1].name) killSpellsIcons[hand][1].entity = v killSpellsIcons[hand][1].entityPosition = Vector(0,0,offset) killSpellsIcons[hand][1].visible = true		 			
						end
					end			
				end
			elseif showDamage[hand].Hits.visible then
				showDamage[hand].HPLeft.visible = false
				showDamage[hand].Hits.visible = false
				killSpellsIcons[hand] = {}
				killItemsIcons[hand] = {}
			end
		end
	end
end
	
function GameClose()
	sleeptick = 0
	onespell = {}
	showDamage = {}
	killSpellsIcons = {} 
	killSpells = {}
	killItemsIcons = {} 
	killItems = {}
	collectgarbage("collect")
end

script:RegisterEvent(EVENT_CLOSE, GameClose)
script:RegisterEvent(EVENT_TICK, Tick)
