require("libs.Utils")
require("libs.HeroInfo")
--[[
                         '''''''''''                               
                     ''''```````````'''''''''''.                   
                 ''''`````````````````````..../.                   
              '''``````````````````````.../////.                   
          ''''``````````````````````...////////.                   
        ''wwwwwwwwww````````````....///////////.                   
         weeeeeeeeeewwwwwwwwww..//////////////.                    
         weeeeeeeeeeeeeeeeeeeew///////////////.                    
          weeeeeeeeeeeeeeeeeeew///////////////.                    
           weeeeeeeeeeeeeeeeeew///////////////.                    
           weeeeeeeeeeeeeeeeeeew//////////////.                    
            weeeeeeeeeeeeeeeeeew/////////////.                     
             weeeeeeeeeeeeeeeeew/////////////.                     
             weeeeeeeeeeeeeeeeew/////////////.                     
              weeeeeeeeeeeeeeeew/////////////.                     
               weeeeeeeeeeeeeeeew////////////.                     
               weeeeeeeeeeeeeeeew///////////.                      
                weeeeeeeeeeeeeeew//////////.                        
                 weeeeeeeeeeeeeew////////..                        
                 weeeeeeeeeeeeeeew//////.                          
                  wweeeeeeeeeeeeew/////.                           
                    wwwweeeeeeeeew////.                              *           
                        wwwweeeeew//..                    *       *              
                            wwwwew/.            * *     **    **      *    
                                ww.             *      **    *     **          
                                                 *      **   * *****    * **   
                                                   *      ****** ** * *     ***
                                                      *** *********           *
        +-------------------------------------------------+   * *  *            
        |                                                 |    *  *** **        
        |       ANIMATIONS LIBRARY - Made by Moones       |    *   *    **      
        |       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^       |    *    *     **    
        +-------------------------------------------------+    *   **      **   
                                                                            *       
        =+=+=+=+=+=+=+=+= VERSION 1.0.2 =+=+=+=+=+=+=+=+=+=
	 
        Description:
        ------------
	
             - This library tracks animations duration of all heroes.
             - Tracks attack animations as well as spell animations.
			 
        Usage:
        ------
		
             - Animations.getDuration(ability) - If specified ability is animating then returns how much time left since ability started its animation.
             - Animations.getAttackDuration(hero) - If specified hero is attacking then returns how much time left since his current attack animation started.
             - Animations.isAttacking(hero) - Returns true if specified hero is currently attacking.
             - Animations.CanMove(hero) - If specified hero already finished his attack and is in his backswing animation then true is returned.
             - Animations.maxCount - Returns how much times per second is library checking. Can be used for sleeps in EVENT_FRAME function.
			 
        Example:
        --------
        
             - Simple OrbWalker:
			 
                 require("libs.Animations")
                 require("libs.Utils")
				 
                 local attack = 0
                 local move = 0
				 
                 function Tick(tick)
                     if PlayingGame() then
                         local me = entityList:GetMyHero()
                         if IsKeyDown(49) then
                             if not Animations.CanMove(me) then
                                 for i,v in ipairs(entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true,team = me:GetEnemyTeam()})) do
                                     if tick > attack GetDistance2D(me, v) <= me.attackRange*2 then
                                         me:Attack(v)
                                         attack = tick + Animations.maxCount/1.5
                                     end
                                 end
                             elseif tick > move then
                                 me:Move(client.mousePosition)
                                 move = tick + Animations.maxCount/1.5
                             end
                         end
                     end
                 end

                 script:RegisterEvent(EVENT_FRAME,Tick)
			 
	   
        Changelog:
        ----------
		
             - 21. 11. 2014 - Version 1.0.2 Fixed bug with tick count.
		
             - 21. 11. 2014 - Version 1.0.1 Now CanMove returning false when hero is casting an ability.
	 
             - 21. 11. 2014 - Version 1.0 First Release
]]--

Animations = {} 

Animations.table = {}
Animations.attacksTable = {}
Animations.startTime = nil
Animations.count = 0
Animations.maxCount = 0
Animations.sleep = 0
Animations.entities = {}

function Animations.trackingTick(tick)
	if not PlayingGame() or client.paused then return end
	if not Animations.startTime then Animations.startTime = client.gameTime
	elseif (client.gameTime < 0 and Animations.startTime > 0) then Animations.startTime = client.gameTime Animations.maxCount = 0 Animations.table = {}
	elseif (client.gameTime - Animations.startTime) >= 1 then Animations.startTime = nil Animations.maxCount = Animations.count Animations.count = 0
	else Animations.count = Animations.count + 1 end
	local creeps, siege, towers, heroes, spirits, wards, wolves
	if tick > Animations.sleep and Animations.maxCount > 0 then
		Animations.entities = {}
		Animations.sleep = 2000
		creeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,alive=true,visible=true})
		siege = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Siege,alive=true,visible=true})
		towers = entityList:GetEntities({classId=CDOTA_BaseNPC_Tower,alive=true,visible=true})
		heroes = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true})
		spirits = entityList:GetEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,alive=true,visible=true})
		wards = entityList:GetEntities({classId=CDOTA_BaseNPC_Venomancer_PlagueWard,alive=true,visible=true})
		wolves = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Neutral,alive=true,visible=true})	
		for _, entity in pairs(creeps) do 
			if entity.spawned and entity.alive and not entity:IsInvul() and not entity:IsAttackImmune() then
				Animations.entities[#Animations.entities + 1] = entity
			end
		end
		for _, entity in pairs(siege) do
			if entity.spawned and entity.alive and not entity:IsInvul() and not entity:IsAttackImmune() then
				Animations.entities[#Animations.entities + 1] = entity
			end	
		end
		for _, entity in pairs(towers) do
			if entity.alive and not entity:IsInvul() and not entity:IsAttackImmune() then
				Animations.entities[#Animations.entities + 1] = entity
			end	
		end
		for _, entity in pairs(heroes) do
			if entity.alive and not entity:IsInvul() and not entity:IsAttackImmune() then
				Animations.entities[#Animations.entities + 1] = entity
			end
		end
		for _, entity in pairs(spirits) do
			if entity.alive and not entity:IsInvul() and not entity:IsAttackImmune() then
				Animations.entities[#Animations.entities + 1] = entity
			end	
		end
		for _, entity in pairs(wolves) do
			if entity.alive and not entity:IsInvul() and not entity:IsAttackImmune() then
				Animations.entities[#Animations.entities + 1] = entity
			end	
		end
		for _, entity in pairs(wards) do
			if entity.alive and not entity:IsInvul() and not entity:IsAttackImmune() then
				Animations.entities[#Animations.entities + 1] = entity
			end	
		end
	end
	for i,v in ipairs(Animations.entities) do
		if (v.hero and not v:IsIllusion()) or not v.hero then
			if not Animations.table[v.handle] then
				Animations.table[v.handle] = {}
			end
			--SleepCheck
			if Animations.table[v.handle].canmove then
				if not Animations.table[v.handle].sleepM or (Animations.startTime and (client.gameTime < 0 and Animations.startTime > 0)) then
					if Animations.maxCount and Animations.maxCount > 0 then
						Animations.table[v.handle].sleepM = tick + math.max((100/Animations.maxCount)*client.latency, 100)
					end
				end
				if Animations.table[v.handle].sleepM then
					if tick < Animations.table[v.handle].sleepM then
						Animations.table[v.handle].sleepingM = true
					end
					if tick > Animations.table[v.handle].sleepM then
						Animations.table[v.handle].sleepingM = false
						Animations.table[v.handle].sleepM = tick + math.max((100/Animations.maxCount)*client.latency, 100)
					end
				end
			end
			if not Animations.table[v.handle].canmove then
				if not Animations.table[v.handle].sleepA or (Animations.startTime and (client.gameTime < 0 and Animations.startTime > 0)) then
					if Animations.maxCount and Animations.maxCount > 0 then
						Animations.table[v.handle].sleepA = tick + math.max((100/Animations.maxCount)*client.latency, 100)
					end
				end
				if Animations.table[v.handle].sleepA then
					if tick < Animations.table[v.handle].sleepA then
						Animations.table[v.handle].sleepingA = true
					end
					if tick > Animations.table[v.handle].sleepA then 
						Animations.table[v.handle].sleepingA = false
						Animations.table[v.handle].sleepA = tick + math.max((100/Animations.maxCount)*client.latency, 100)
					end
				end
			end
			--SpellAnimationCheck
			if v.abilities then
				for i,k in ipairs(v.abilities) do
					if k.abilityPhase then
						if not Animations.table[k.handle] then                                   
							Animations.table[k.handle] = {}
							Animations.table[k.handle].startTime = tick
							Animations.table[k.handle].duration = tick - Animations.table[k.handle].startTime
							Animations.table[v.handle].canmove = false
						end
					else
						Animations.table[k.handle] = nil
					end
					if Animations.table[k.handle] then
						Animations.table[k.handle].duration = tick - Animations.table[k.handle].startTime
						Animations.table[v.handle].canmove = false
					end
				end
			end
			local hero = HeroInfo(v)
			if hero and heroInfo[v.name] then
				hero:Update()
				Animations.table[v.handle].attackTime = hero.attackPoint - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount))) + (1/Animations.maxCount)*3*(1 + (1 - 1/Animations.maxCount))
				Animations.table[v.handle].moveTime = (hero.attackRate) - (client.latency/1000) - (1/Animations.maxCount)*3
				
				--AttackAnimationCheck
				if Animations.isAttacking(v) then
					if not Animations.table[v.handle].startTime then
						Animations.table[v.handle].startTime = client.gameTime
					end
					Animations.table[v.handle].endTime = Animations.table[v.handle].startTime + (hero.attackRate) - (client.latency/1000) - (1/Animations.maxCount)*3
					Animations.table[v.handle].canmoveTime = Animations.table[v.handle].startTime + hero.attackPoint - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount))) + (1/Animations.maxCount)*3*(1 + (1 - 1/Animations.maxCount))
				end
				--FlyingProjectilesCheck
				local projs = entityList:GetProjectiles({source=v})
				for k,z in ipairs(projs) do
					if GetDistance2D(z.position, v.position) < 127 and not Animations.table[v.handle].canmove then
						Animations.table[v.handle].canmove = true
						Animations.table[v.handle].endTime = client.gameTime + (hero.attackBackswing) - (client.latency/1000) - (1/Animations.maxCount)*3
					end
				end
				if Animations.table[v.handle].endTime and Animations.table[v.handle].endTime <= client.gameTime then
					Animations.table[v.handle].startTime = nil
					Animations.table[v.handle].canmoveTime = nil 
					Animations.table[v.handle].endTime = nil
					Animations.table[v.handle].canmove = false
					return
				end
				if Animations.table[v.handle].startTime then
					Animations.table[v.handle].duration = client.gameTime - Animations.table[v.handle].startTime + 1/Animations.maxCount + client.latency/1000
				end
				if Animations.table[v.handle].canmoveTime and client.gameTime >= Animations.table[v.handle].canmoveTime then
					Animations.table[v.handle].canmove = true
				end
			end
		end
	end 
end

function Animations.trackLoad()
	Animations.count = 0
	Animations.maxCount = 0
	Animations.entities = {}
end

function Animations.getCount()
	return Animations.count
end

function Animations.getDuration(ability)
	if ability and Animations.table[ability.handle] then return Animations.table[ability.handle].duration else return 0 end
end

function Animations.getAttackDuration(hero)
	if hero and Animations.table[hero.handle] and Animations.table[hero.handle].duration then return Animations.table[hero.handle].duration else return 0 end
end

function Animations.isAnimating(ability)
	return ability.abilityPhase
end

function Animations.isAttacking(hero)
	return hero.activity == LuaEntityNPC.ACTIVITY_ATTACK or hero.activity == LuaEntityNPC.ACTIVITY_ATTACK1 or hero.activity == LuaEntityNPC.ACTIVITY_ATTACK2 or hero.activity == LuaEntityNPC.ACTIVITY_CRIT
end

function Animations.CanMove(hero)
	if Animations.table[hero.handle] then return Animations.table[hero.handle].canmove end
end

function Animations.GetAttackTime(hero)
	if hero and Animations.table[hero.handle] and Animations.table[hero.handle].attackTime then return Animations.table[hero.handle].attackTime elseif HeroInfo(hero) and HeroInfo(hero).attackPoint then return HeroInfo(hero).attackPoint - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount))) + (1/Animations.maxCount)*3*(1 + (1 - 1/Animations.maxCount))
	end
	return 0
end

class 'HeroInfo'

function HeroInfo:__init(entity)   
	self.entity = entity
	local name = entity.name
	if not heroInfo[name] then
		return nil
	end
	self.baseAttackPoint = heroInfo[name].attackPoint
	self.baseBackswing = heroInfo[name].attackBackswing
end

function HeroInfo:Update()	
	self.attackSpeed = self:GetAttackSpeed()
	self.attackRate = self:GetAttackRate()
	self.attackPoint = self:GetAttackPoint()
	self.attackBackswing = self:GetBackswing()
end

function HeroInfo:GetAttackSpeed()
	if self.entity.attackSpeed > 500 then
		return 500
	end
	return self.entity.attackSpeed
end

function HeroInfo:GetAttackPoint()
	return self.baseAttackPoint / (1 + (self.entity.attackSpeed - 100) / 100)
end

function HeroInfo:GetAttackRate()
	local alchrage = self.entity:FindSpell("alchemist_chemical_rage")
	if alchrage and alchrage.level > 0 and self.entity:DoesHaveModifier("modifier_alchemist_chemical_rage") then
		return alchrage:GetSpecialData("base_attack_time",alchrage.level) / (1 + (self.entity.attackSpeed - 100) / 100)
	end
	local terrormorph = self.entity:FindSpell("terrorblade_metamorphosis")
	if terrormorph and terrormorph.level > 0 and self.entity:DoesHaveModifier("modifier_terrorblade_metamorphosis") then
		return terrormorph:GetSpecialData("base_attack_time",terrormorph.level) / (1 + (self.entity.attackSpeed - 100) / 100)
	end
	local lonetrue = self.entity:FindSpell("lone_druid_true_form")
	if lonetrue and lonetrue.level > 0 and self.entity:DoesHaveModifier("modifier_lone_druid_true_form") then
		return lonetrue:GetSpecialData("base_attack_time",lonetrue.level) / (1 + (self.entity.attackSpeed - 100) / 100)
	end
	return self.entity.attackBaseTime / (1 + (self.entity.attackSpeed - 100) / 100)
end

function HeroInfo:GetBackswing()
	return self.baseBackswing / (1 + (self.entity.attackSpeed - 100) / 100)
end
	
scriptEngine:RegisterLibEvent(EVENT_FRAME,Animations.trackingTick)
scriptEngine:RegisterLibEvent(EVENT_LOAD,Animations.trackLoad)