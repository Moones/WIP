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
        =+=+=+=+=+=+=+=+=+ VERSION 1.0 +=+=+=+=+=+=+=+=+=+=
	 
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
                                     if tick > attack then
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
	
             - 20. 11. 2014 - Version 1.0 First Release
]]--

Animations = {}

Animations.table = {}
Animations.attacksTable = {}
Animations.startTime = nil
Animations.count = 0
Animations.maxCount = 0

function Animations.trackingTick(tick)
	if not Animations.startTime then Animations.startTime = client.gameTime
	elseif (client.gameTime - Animations.startTime) >= 1 then Animations.startTime = nil Animations.count = 0
	else Animations.count = Animations.count + 1 if Animations.count > Animations.maxCount then Animations.maxCount = Animations.count end end
	
	for i,v in ipairs(entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true})) do
		for i,k in ipairs(v.abilities) do
			if k.abilityPhase then
				if not Animations.table[k.handle] then 
					Animations.table[k.handle] = {}
					Animations.table[k.handle].startTime = tick
					Animations.table[k.handle].duration = tick - Animations.table[k.handle].startTime
				end
			else
				Animations.table[k.handle] = nil
			end
			if Animations.table[k.handle] then
				Animations.table[k.handle].duration = tick - Animations.table[k.handle].startTime
			end
		end
		local hero = Hero(v)
		hero:Update()
		if Animations.isAttacking(v) then
			if not Animations.table[v.handle] then
				Animations.table[v.handle] = {}
				Animations.table[v.handle].startTime = tick
				Animations.table[v.handle].duration = tick - Animations.table[v.handle].startTime
				Animations.table[v.handle].endTime = tick + (hero.attackRate)*1000
				Animations.table[v.handle].attacktime = (hero.attackPoint + hero.attackBackswing)*1000
			end
		elseif Animations.table[v.handle] and Animations.table[v.handle].endTime <= tick then
			Animations.table[v.handle] = nil
		end
		if Animations.table[v.handle] then
			Animations.table[v.handle].duration = tick - Animations.table[v.handle].startTime
			if (Animations.table[v.handle].duration - hero.attackBackswing*1000) >= 0 then
				Animations.table[v.handle].canmove = true
			else
				Animations.table[v.handle].canmove = false
			end
		end
	end
end

function Animations.getCount()
	return Animations.count
end

function Animations.getDuration(ability)
	if ability and Animations.table[ability.handle] then return Animations.table[ability.handle].duration/1000 else return 0 end
end

function Animations.getAttackDuration(hero)
	if hero and Animations.table[hero.handle] then return Animations.table[hero.handle].duration/1000 else return 0 end
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

class 'Hero'

function Hero:__init(entity)   
	self.entity = entity
	local name = entity.name
	if not heroInfo[name] then
		return nil
	end
	self.baseAttackRate = heroInfo[name].attackRate
	self.baseAttackPoint = heroInfo[name].attackPoint
	self.baseBackswing = heroInfo[name].attackBackswing
end

function Hero:Update()	
	self.attackSpeed = self:GetAttackSpeed()
	self.attackRate = self:GetAttackRate()
	self.attackPoint = self:GetAttackPoint()
	self.attackRange = self:GetAttackRange()
	self.attackBackswing = self:GetBackswing()
end

function Hero:GetAttackRange()
	local bonus = 0
	if self.entity.classId == CDOTA_Unit_Hero_TemplarAssassin then
		local psy = self.entity:GetAbility(3)
		local psyrange = psy:GetSpecialData("bonus_attack_range",psy.level)		
		if psy and psy.level > 0 then		
			bonus = psyrange	
		end
	elseif self.entity.classId == CDOTA_Unit_Hero_Sniper then
			local aim = self.entity:GetAbility(3)
			aimrange = {100,200,300,400}			
			if aim and aim.level > 0 then			
				bonus = aimrange[aim.level]				
			end			
		end
	return self.entity.attackRange + bonus + 25
end

function Hero:GetAttackSpeed()
	if self.entity.attackSpeed > 500 then
		return 500
	end
	return self.entity.attackSpeed
end

function Hero:GetAttackPoint()
	return self.baseAttackPoint / (1 + (self.entity.attackSpeed - 100) / 100)
end

function Hero:GetAttackRate()
	return self.entity.attackBaseTime / (1 + (self.entity.attackSpeed - 100) / 100)
end

function Hero:GetBackswing()
	return self.baseBackswing / (1 + (self.entity.attackSpeed) / 100)
end
	
scriptEngine:RegisterLibEvent(EVENT_FRAME,Animations.trackingTick)
