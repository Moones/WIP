--<<Shows how much damage you will deal with your spells+items and how much hits you will need to kill enemy>>
require("libs.ScreenPosition")
require("libs.AbilityDamage")
require("libs.Animations")
require("libs.Utils")
require("libs.ScriptConfig")

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
		- Supports calculating of EtherealBlade damage amplification, expecting that you will cast EtherealBlade first.
		 
        Changelog:
        ----------
		
		v0.5 - Fixed calculations for many heroes
		
		v0.1 - BETA Release
		
]]--

--Preparation for calculating position/size difference between resolutions
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

--Config
local config = ScriptConfig.new()
config:SetParameter("Color", 450)
config:Load()


--Variables
local showDamage = {} local killSpellsIcons = {} local killSpells = {} local killItemsIcons = {} local killItems = {} local sleeptick = 0 local onespell = {} local attack_modifier = nil
local monitor = client.screenSize.x/1600
local F13 = drawMgr:CreateFont("F13","Tahoma",13*monitor,650*monitor)

--Main function
function Tick(tick)
	if not PlayingGame() or client.console or tick < sleeptick then return end sleeptick = tick + 125
	
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
			
			--We have ethereal blade so we write it down into ethMult variable
			if eth and eth:CanBeCasted() then
				ethMult = true
			end
			
			if v.visible and v.alive then
				--Calculating damage from items
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
						--every magical damage is amplificated by EtherealBlade
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
				
				--Calculating damage from spells
				for h,k in ipairs(abilities) do
					local damage = AbilityDamage.GetDamage(k)
					if k.name == "antimage_mana_void" then
						damage = (v.maxMana - v.mana)*damage
					end
					--Recongnizing the type of damage of our spell
					local dmgType = k.dmgType
					local type
					if dmgType == 1 then
						type = DAMAGE_PHYS
					elseif dmgType == 2 then
						type = DAMAGE_MAGC
					elseif dmgType == 4 then
						type = DAMAGE_PURE
					end
					if k.name == "abaddon_aphotic_shield" then type = DAMAGE_MAGC end
					if k.name == "axe_culling_blade" then type = DAMAGE_PURE end
					if k.name == "alchemist_unstable_concoction_throw" then type = DAMAGE_PHYS end
					if k.name == "centaur_stampede" then type = DAMAGE_MAGC end
					if k.name == "lina_laguna_blade" and me:AghanimState() then type = DAMAGE_PURE end	
					local takenDmg
					
					--Bristleback's Quill Spray stacks
					if me.classId == CDOTA_Unit_Hero_Bristleback then
						local quill_modif = v:FindModifier("modifier_bristleback_quill_spray")
						local quill_spell = me:FindSpell("bristleback_quill_spray")
						if quill_spell.level > 0 and k.name == "bristleback_quill_spray" then
							if quill_modif then
								damage = math.min(damage + quill_spell:GetSpecialData("quill_stack_damage",quill_spell.level)*quill_modif.stacks,400)
							end
						end
					end
					
					--Doom's Lvl? Death
					if k.name == "doom_bringer_lvl_death" then
						local multiplier = k:GetSpecialData("lvl_bonus_multiple",k.level)
						local bonusPercent = k:GetSpecialData("lvl_bonus_damage")/100
						if (v.level/multiplier) == math.floor(v.level/multiplier) or v.level == 25 then
							damage = damage + v.maxHealth*bonusPercent
						end
					end
					
					if v.health < v.maxHealth or (v.health - totalDamage) < v.maxHealth then
						takenDmg = math.ceil(v:DamageTaken(damage,type,me) - ((v.healthRegen)*(k:FindCastPoint() + k:GetChannelTime(k.level) + client.latency/1000)))
					else
						takenDmg = math.ceil(v:DamageTaken(damage,type,me) - ((v.healthRegen)*(k:GetChannelTime(k.level))))
					end
					--every magical damage is amplificated by EtherealBlade
					if ethMult and type == DAMAGE_MAGC then
						takenDmg = takenDmg*1.4
					end
					--Spell will not be registered if it is modifying hero auto attack, in that case we store its bonus damage and add it to our autoAttack damage when calculating hits.
					if AbilityDamage.attackModifiersList[k.name] then
						if AbilityDamage.attackModifiersList[k.name].manaBurn then
							attack_modifier = math.ceil(v:ManaBurnDamageTaken(damage,1,type,me))
						else
							attack_modifier = takenDmg
						end
					else
						if k.level > 0 and (k:CanBeCasted() or k.abilityPhase or (me:DoesHaveModifier("modifier_"..k.name) and k.name ~= "centaur_stampede" and k.name ~= "crystal_maiden_freezing_field")) and damage and damage > 0 and (k.name ~= "bounty_hunter_jinada" or k.cd == 0) then
							if (v.health - takenDmg) <= 0 then
								if not onespell[hand] or (onespell[hand][2] > h or (k.name == "axe_culling_blade" and onespell[hand][1].name ~= "axe_culling_blade")) then
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
							--Calculating damage bonuses for unique spells:
							
							--Zeus's Static Field
							if me.classId == CDOTA_Unit_Hero_Zuus then
								local staticF = me:GetAbility(3)
								if staticF and staticF.level > 0 then
									takenDmg = takenDmg + v:DamageTaken(((staticF:GetSpecialData("damage_health_pct",staticF.level)/100)*(v.health - totalDamage)),DAMAGE_MAGC,me)
								end
							end
						
							--Ancient Apparition's Ice Blast
							if k.name == "ancient_apparition_ice_blast" then
								local percent = k:GetSpecialData("kill_pct", k.level)/100
								percent = v.maxHealth*percent
								if (v.health - (totalDamage + takenDmg)) <= percent then
									takenDmg = takenDmg + percent
								end
							end
						
							--Batrider's Sticky Napalm stacks
							if me.classId == CDOTA_Unit_Hero_Batrider then
								local stickyM = v:FindModifier("modifier_batrider_sticky_napalm")
								local stickyN = me:FindSpell("batrider_sticky_napalm")
								if stickyN.level > 0 then
									if stickyM then
										takenDmg = takenDmg + v:DamageTaken(stickyN:GetSpecialData("damage",stickyN.level)*stickyM.stacks,DAMAGE_MAGC,me)
										attack_modifier = v:DamageTaken(stickyN:GetSpecialData("damage",stickyN.level)*stickyM.stacks,DAMAGE_MAGC,me)
									else
										attack_modifier = nil
									end
								end
							end
							totalDamage = totalDamage + takenDmg
						end
						if damage and damage > 0 and k.name ~= "crystal_maiden_freezing_field" and ((v:DoesHaveModifier("modifier_"..k.name) and me:DoesHaveModifier("modifier_"..k.name) and k.cd > 0) or k.abilityPhase) then sleeptick = tick + k:FindCastPoint()*3000 + k:GetChannelTime(k.level)*500 + client.latency return end
					end
				end
			end
			
			--Converting position and size of our drawings into other resolutions
			local x,y,w,h
			local x1,y1,w1,h1
			if math.floor(client.screenRatio*100) == 133 then
				x,y,w,h = sPos:GetPosition(37, 24, 72, 10)
				x1,y1,w1,h1 = sPos:GetPosition(27, 9, 11, 14)
			elseif math.floor(client.screenRatio*100) == 166 then
				x,y,w,h = sPos:GetPosition(37, 23, 71, 7)
				x1,y1,w1,h1 = sPos:GetPosition(27, 8, 12, 12)
			elseif math.floor(client.screenRatio*100) == 177 then
				x,y,w,h = sPos:GetPosition(43, 28, 83.5, 10)
				x1,y1,w1,h1 = sPos:GetPosition(30, 10, 13, 14)
			elseif math.floor(client.screenRatio*100) == 160 then
				x,y,w,h = sPos:GetPosition(37, 25, 74, 8)
				x1,y1,w1,h1 = sPos:GetPosition(27, 9, 11, 13)
			elseif math.floor(client.screenRatio*100) == 125 then
				x,y,w,h = sPos:GetPosition(48, 32, 94, 10)
				x1,y1,w1,h1 = sPos:GetPosition(31, 11, 15, 14)
			else
				x,y,w,h = sPos:GetPosition(43, 28, 83, 10)
				x1,y1,w1,h1 = sPos:GetPosition(30, 10, 13, 14)
			end
			
			--Drawings
			if not showDamage[hand] then showDamage[hand] = {}
				showDamage[hand].HPLeft = drawMgr:CreateRect(-x,-y+1,0,h,config.Color) showDamage[hand].HPLeft.visible = false showDamage[hand].HPLeft.entity = v showDamage[hand].HPLeft.entityPosition = Vector(0,0,offset)
				showDamage[hand].Hits = drawMgr:CreateText(-x,-y+15, 0xFFFFFF99, "",F13) showDamage[hand].Hits.visible = false showDamage[hand].Hits.entity = v showDamage[hand].Hits.entityPosition = Vector(0,0,offset)					
			end
			local hpleft = math.max(v.health - totalDamage, 0)
			if v.visible and v.alive then
				local HPLeftPercent = hpleft/v.maxHealth
				local hitDamage = v:DamageTaken(((me.dmgMin + me.dmgMax)/2 + me.dmgBonus),DAMAGE_PHYS,me)
				if attack_modifier then
					hitDamage = hitDamage + attack_modifier
				end
				local hits = math.ceil(hpleft/hitDamage)
				if totalDamage > 0 then
					showDamage[hand].HPLeft.visible = true showDamage[hand].HPLeft.w = w*HPLeftPercent
				elseif showDamage[hand].HPLeft.visible then
					showDamage[hand].HPLeft.visible = false
				end
				if hits > 0 then
					if Animations.table[me.handle] and Animations.table[me.handle].moveTime and Animations.maxCount > 0 then
						hits = math.ceil((hpleft + ((v.healthRegen)*((Animations.table[me.handle].moveTime)*hits)))/hitDamage)
					end
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
									killSpellsIcons[hand][i] = drawMgr:CreateRect(-x/monitor+20*monitor+(17*monitor*i),-y+y1*monitor,w1*monitor,h1*monitor,0x000000FF) killSpellsIcons[hand][i].textureId = drawMgr:GetTextureId("NyanUI/Spellicons/"..ks) killSpellsIcons[hand][i].entity = v killSpellsIcons[hand][i].entityPosition = Vector(0,0,offset) killSpellsIcons[hand][i].visible = true		 			
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
									killItemsIcons[hand][i] = drawMgr:CreateRect(-x/monitor+20*monitor+(17*monitor*i),-y+yy*monitor,w1*monitor + 7*monitor,h1*monitor,0x000000FF) killItemsIcons[hand][i].textureId = drawMgr:GetTextureId("NyanUI/items/"..ks:gsub("item_","")) killItemsIcons[hand][i].entity = v killItemsIcons[hand][i].entityPosition = Vector(0,0,offset) killItemsIcons[hand][i].visible = true		 			
								end
							end
						end
					else
						killSpellsIcons[hand] = {}
						if onespell[hand][3] then
							killSpellsIcons[hand][1] = drawMgr:CreateRect(-x/monitor+x1*monitor,-y+y1*monitor,w1*monitor,h1*monitor,0x000000FF) killSpellsIcons[hand][1].textureId = drawMgr:GetTextureId("NyanUI/items/"..onespell[hand][1].name:gsub("item_","")) killSpellsIcons[hand][1].entity = v killSpellsIcons[hand][1].entityPosition = Vector(0,0,offset) killSpellsIcons[hand][1].visible = true		 			
						else
							killSpellsIcons[hand][1] = drawMgr:CreateRect(-x/monitor+x1*monitor,-y+y1*monitor,w1*monitor,h1*monitor,0x000000FF) killSpellsIcons[hand][1].textureId = drawMgr:GetTextureId("NyanUI/Spellicons/"..onespell[hand][1].name) killSpellsIcons[hand][1].entity = v killSpellsIcons[hand][1].entityPosition = Vector(0,0,offset) killSpellsIcons[hand][1].visible = true		 			
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
	attack_modifier = nil
	collectgarbage("collect")
end

script:RegisterEvent(EVENT_CLOSE, GameClose)
script:RegisterEvent(EVENT_TICK, Tick)
