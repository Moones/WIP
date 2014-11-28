require("libs.Utils")
require("libs.Animations")
require("libs.HeroInfo")
--[[
                             ___
                            ( ((
                             ) ))              
  .::.   LASTHIT LIBRARY    / /(   MADE BY MOONES      
 'M .-;-.-.-.-.-.-.-.-.-.-/| ((:::::::::::::::::::::::::::::::::::::::::::::.._
(O ( ( ( ( ( ( ( ( ( ( ( ( |  ))   -===========VERSION 1.0.0===========-      _.>
 `M `-;-`-`-`-`-`-`-`-`-`-\| ((::::::::::::::::::::::::::::::::::::::::::::::''
  `::'                      \ \(
        Description:         ) ))
        ------------        (_((                           		 
        
         Lasthit.GetLastHit(hero) - Use this in your script when your hero is able to attack. It will execute attack command to a creep which can be lasthitted by your hero.
		 
        Changelog:
        ----------
		
		 VERSION 1.0.0 - asdfghjklqwertzuiop. Fixed yxcvmnbyxcvljhsgdfjasdasiudghasjd.
		
]]--

Lasthit = {}
Lasthit.creepTable = {}
Lasthit.table = {}
Lasthit.armorTypeModifiers = { Normal = {Unarmored = 1.00, Light = 1.00, Medium = 1.50, Heavy = 1.25, Fortified = 0.70, Hero = 0.75}, Pierce = {Unarmored = 1.50, Light = 2.00, Medium = 0.75, Heavy = 0.75, Fortified = 0.35, Hero = 0.50}, Siege = {Unarmored = 1.00, Light = 1.00, Medium = 0.50, Heavy = 1.25, Fortified = 1.50, Hero = 0.75}, Chaos = {Unarmored = 1.00, Light = 1.00, Medium = 1.00, Heavy = 1.00, Fortified = 0.40, Hero = 1.00},	Hero = {Unarmored = 1.00, Light = 1.00, Medium = 1.00, Heavy = 1.00, Fortified = 0.50, Hero = 1.00}, Magic = {Unarmored = 1.00, Light = 1.00, Medium = 1.00, Heavy = 1.00, Fortified = 1.00, Hero = 0.75} }
Lasthit.sleepTick = 0

function Lasthit.Tick(tick)
	if not PlayingGame() or client.paused then return end
	if Animations.maxCount and Animations.maxCount > 0 and tick > Lasthit.sleepTick  then
		Lasthit.mapCreeps()
		Lasthit.sleepTick = tick + 2000
	end
	local me = entityList:GetMyHero()
	for creepHandle, creepClass in pairs(Lasthit.creepTable) do
		if not creepClass.creepEntity.visible or not creepClass.creepEntity.alive or GetDistance2D(me, creepClass.creepEntity) > Lasthit.AttackRange(me)*2+800 then
			Lasthit.creepTable[creepHandle] = nil
		else
			creepClass:Update()
		end
	end
end

function Lasthit.close()
	Lasthit.creepTable = {}
	Lasthit.table = {}
end

function Lasthit.GetLasthit(hero)
	if hero then
		if Lasthit.table[hero.handle] and (not Lasthit.table[hero.handle].alive or not Lasthit.table[hero.handle].visible) then
			Lasthit.table[hero.handle] = nil
		end
		for creepHandle, creepClass in pairs(Lasthit.creepTable) do	
			if creepClass.creepEntity.team ~= hero.team and GetDistance2D(hero, creepClass.creepEntity) < 800 then
				local Dmg = GetDamage(hero,creepClass)
				local timeToHealth = creepClass:GetTimeToHealth(Dmg)
				local timeToDie = creepClass:GetTimeToHealth(0)
				local myattackTime = (client.gameTime + Animations.GetAttackTime(hero) - client.latency/1000)
				if heroInfo[hero.name].projectileSpeed then
					myattackTime = myattackTime + ((GetDistance2D(hero, creepClass.creepEntity)-100-math.max((GetDistance2D(hero, creepClass.creepEntity) - Lasthit.AttackRange(hero)), 0))/heroInfo[hero.name].projectileSpeed)
				end				
				if hero.team ~= creepClass.creepEntity.team then
					if ((timeToDie and timeToDie > myattackTime) or not timeToDie) and (Dmg >= creepClass.creepEntity.health or (timeToHealth and timeToHealth < myattackTime)) then
						if not Lasthit.table[hero.handle] or not Lasthit.table[hero.handle].alive or not Lasthit.table[hero.handle].visible then
							Lasthit.table[hero.handle] = creepClass.creepEntity
							Lasthit.table[hero.handle].class = creepClass
						end
					end
				end
			end
		end
	end
end	

function StopAttack(hero,target,creepClass)
	if hero and target and target.alive then
		local Dmg = GetDamage(hero,creepClass)
		local timeToHealth = creepClass:GetTimeToHealth(Dmg)
		local timeToDie = creepClass:GetTimeToHealth(0)
		local myattackTime = (client.gameTime + Animations.GetAttackTime(hero)  - client.latency/1000)
		if heroInfo[hero.name].projectileSpeed then
			myattackTime = myattackTime + ((GetDistance2D(hero, target)-100-math.max((GetDistance2D(hero, target) - Lasthit.AttackRange(hero)), 0))/heroInfo[hero.name].projectileSpeed)
		end
		if ((timeToDie and timeToDie > myattackTime) or not timeToDie) and (timeToHealth and timeToHealth > myattackTime) and (target.health > Dmg) and Animations.isAttacking(hero) then
			hero:Stop()
			return true
		end
	end
end

function Lasthit.mapCreeps()
	local me = entityList:GetMyHero()
	local creeps, siege, towers, heroes, spirits, wards, wolves
	creeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,alive=true,visible=true})
	siege = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Siege,alive=true,visible=true})
	towers = entityList:GetEntities({classId=CDOTA_BaseNPC_Tower,alive=true,visible=true})
	heroes = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true})
	spirits = entityList:GetEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,alive=true,team=me:GetEnemyTeam(),visible=true})
	wards = entityList:GetEntities({classId=CDOTA_BaseNPC_Venomancer_PlagueWard,alive=true,visible=true})
	wolves = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Neutral,alive=true,team=me:GetEnemyTeam(),visible=true})
	
	for _, entity in ipairs(creeps) do 
		if entity.spawned and entity.alive and GetDistance2D(me, entity) < Lasthit.AttackRange(me)*2+800 and not Lasthit.creepTable[entity.handle] and not entity:IsInvul() and not entity:IsAttackImmune() then
			Lasthit.creepTable[entity.handle] = Creep(entity)
		end
	end
	for _, entity in ipairs(siege) do
		if entity.spawned and entity.alive and GetDistance2D(me, entity) < Lasthit.AttackRange(me)*2+800 and not Lasthit.creepTable[entity.handle] and not entity:IsInvul() and not entity:IsAttackImmune() then
			Lasthit.creepTable[entity.handle] = Creep(entity)
		end	
	end
	for _, entity in ipairs(towers) do
		if entity.alive and GetDistance2D(me, entity) < Lasthit.AttackRange(me)*2+800 and not Lasthit.creepTable[entity.handle] and not entity:IsInvul() and not entity:IsAttackImmune() then
			Lasthit.creepTable[entity.handle] = Creep(entity)
		end	
	end
	for _, entity in ipairs(heroes) do
		if entity.handle ~= me.handle and entity.alive and GetDistance2D(me, entity) < Lasthit.AttackRange(me)*2+800 and not Lasthit.creepTable[entity.handle] and not entity:IsInvul() and not entity:IsAttackImmune() then
			Lasthit.creepTable[entity.handle] = Creep(entity)
		end
	end
	for _, entity in ipairs(spirits) do
		if entity.alive and GetDistance2D(me, entity) < Lasthit.AttackRange(me)*2+800 and not Lasthit.creepTable[entity.handle] and not entity:IsInvul() and not entity:IsAttackImmune() then
			Lasthit.creepTable[entity.handle] = Creep(entity)
		end	
	end
	for _, entity in ipairs(wolves) do
		if entity.alive and GetDistance2D(me, entity) < Lasthit.AttackRange(me)*2+800 and not Lasthit.creepTable[entity.handle] and not entity:IsInvul() and not entity:IsAttackImmune() then
			Lasthit.creepTable[entity.handle] = Creep(entity)
		end	
	end
	for _, entity in ipairs(wards) do
		if entity.alive and GetDistance2D(me, entity) < Lasthit.AttackRange(me)*2+800 and not Lasthit.creepTable[entity.handle] and not entity:IsInvul() and not entity:IsAttackImmune() then
			Lasthit.creepTable[entity.handle] = Creep(entity)
		end	
	end
end

function Lasthit.AttackRange(unit)
	local bonus = 0
	if unit.classId == CDOTA_Unit_Hero_TemplarAssassin then	
		local psy = unit:GetAbility(3)
		if psy and psy.level > 0 then		
			bonus = psy:GetSpecialData("bonus_attack_range",psy.level)			
		end
	elseif unit.classId == CDOTA_Unit_Hero_Sniper then	
		local aim = unit:GetAbility(3)		
		if aim and aim.level > 0 then		
			bonus = aim:GetSpecialData("bonus_attack_range",aim.level)		
		end		
	elseif unit.classId == CDOTA_Unit_Hero_Enchantress then
		if enablemodifiers then
			local impetus = unit:GetAbility(4)
			if impetus.level > 0 and unit:AghanimState() then
				bonus = 190
			end
		end
	end
	return unit.attackRange + bonus
end


function GetDamage(hero,target,crit)
	local dmg = hero.dmgMin + hero.dmgBonus
	local qblade = hero:FindItem("item_quelling_blade")
	local magical = nil
	if target.creepEntity.team ~= hero.team then
		if attackmodifiers then
			if hero.classId == CDOTA_Unit_Hero_Clinkz then
			
				local searinga = hero:GetAbility(2)
				searingDmg = {30,40,50,60}
				
				if searinga.level > 0 then
					dmg = dmg + searingDmg[searinga.level]
				end
			end
		end
		if hero.classId == CDOTA_Unit_Hero_AntiMage then		
			local manabreak = hero:GetAbility(1)
			manaburned = {28,40,52,64}			
			if manabreak.level > 0 and target.creepEntity.maxMana > 0 and target.creepEntity.mana > 0 then
				dmg = dmg + manaburned[manabreak.level]*0.6
			end
		elseif hero.classId == CDOTA_Unit_Hero_Viper then
			local nethertoxin = hero:GetAbility(2)
			nethertoxindmg = {2.5,5,7.5,10}
			if nethertoxin.level > 0 then					
				local hplosspercent = target.creepEntity.health/(target.creepEntity.maxHealth / 100)
				local netherdmg = nil					
				if hplosspercent > 80 and hplosspercent <= 100 then
					netherdmg = nethertoxindmg[nethertoxin.level]*0.5
				elseif hplosspercent > 60 and hplosspercent <= 80 then
					netherdmg = nethertoxindmg[nethertoxin.level]*1
				elseif hplosspercent > 40 and hplosspercent <= 60 then
					netherdmg = nethertoxindmg[nethertoxin.level]*2
				elseif hplosspercent > 20 and hplosspercent <= 40 then
					netherdmg = nethertoxindmg[nethertoxin.level]*4
				elseif hplosspercent > 0 and hplosspercent <= 20 then
					netherdmg = nethertoxindmg[nethertoxin.level]*8
				end					
				if netherdmg then
					dmg = dmg + netherdmg
				end					
			end
		elseif hero.classId == CDOTA_Unit_Hero_Ursa then
			local furyswipes = hero:GetAbility(3)
			local furymodif = target.creepEntity:FindModifier("modifier_ursa_fury_swipes_damage_increase")
			furydmg = {15,20,25,30}
			if furyswipes.level > 0 then
				if furymodif then
					dmg = dmg + furydmg[furyswipes.level]*furymodif.stacks
				else
					dmg = dmg + furydmg[furyswipes.level]
				end
			end
		elseif hero.classId == CDOTA_Unit_Hero_BountyHunter then
			local jinada = hero:GetAbility(2)
			jinadadmg = {1.5,1.75,2,2.25}
			if jinada.level > 0 and crit and jinada.cd < (Animations.table[hero.handle].attackTime + (math.max((GetDistance2D(hero, target.creepEntity) - Lasthit.AttackRange(hero)), 0)/hero.movespeed)/1.1) then
				crit = nil
				dmg = dmg*(jinadadmg[jinada.level]-0.2)
			end
		elseif hero.classId == CDOTA_Unit_Hero_Weaver then
			local geminate = hero:GetAbility(3)
			if geminate.level > 0 and target.creepEntity.health > dmg*1.3 and geminate.cd < (Animations.table[hero.handle].attackTime + (math.max((GetDistance2D(hero, target.creepEntity) - Lasthit.AttackRange(hero)), 0)/hero.movespeed) + ((GetDistance2D(hero, target.creepEntity)-math.max((GetDistance2D(hero, target.creepEntity) - Lasthit.AttackRange(hero)), 0))/heroInfo[hero.name].projectileSpeed)/1.1) then
				geminate_attack = ((GetDistance2D(hero, target.creepEntity)-math.max((GetDistance2D(hero, target.creepEntity) - Lasthit.AttackRange(hero)), 0))/heroInfo[hero.name].projectileSpeed)*1000 + geminate.cd*100 + Animations.table[hero.handle].attackTime
				dmg = dmg*2
			else
				geminate_attack = 0
			end
		elseif hero.classId == CDOTA_Unit_Hero_Juggernaut or hero.classId == CDOTA_Unit_Hero_Brewmaster then
			local doublecrit = hero:GetAbility(3)
			if doublecrit.level > 0 and crit then crit = nil
				dmg = dmg*1.8
			end
		elseif hero.classId == CDOTA_Unit_Hero_ChaosKnight or hero.classId == CDOTA_Unit_Hero_SkeletonKing then
			local lowcrit = hero:GetAbility(3)
			lowcritdmg = {1.5,2,2.5,3}
			if lowcrit.level > 0 and crit then crit = nil
				dmg = dmg*(lowcritdmg[lowcrit.level]-0.2)
			end
		elseif hero.classId == CDOTA_Unit_Hero_PhantomAssassin then
			local highcrit = hero:GetAbility(4)
			highcritdmg = {2.5,3.5,4.5}
			if highcrit.level > 0 and crit then crit = nil
				dmg = dmg*(highcritdmg[highcrit.level]-0.2)
			end
		end
		if qblade then
			if hero.attackRange < 200 then
				dmg = dmg*1.32
			else
				dmg = dmg*1.12
			end
		end
	end
	
	if hero.classId == CDOTA_Unit_Hero_Kunkka then
		local tidebringer = hero:GetAbility(2)
		tidebringerdmg = {15,30,45,60}
		if tidebringer.level > 0 and tidebringer.cd < (Animations.table[hero.handle].attackTime + client.latency/1100 + (math.max((GetDistance2D(hero, target.creepEntity) - Lasthit.AttackRange(hero)), 0)/hero.movespeed)/1.1) then
			dmg = dmg+(tidebringerdmg[tidebringer.level]/1.1)
		end
	end
	dmg = (math.floor(dmg * Lasthit.armorTypeModifiers["Hero"][target.armorType] * (1 - target.creepEntity.dmgResist)))		
	return dmg
end 

function Hit(hero,target)
	if target.team ~= hero.team then
		if hero.classId == CDOTA_Unit_Hero_Clinkz then
			local searinga = hero:GetAbility(2)
			if searinga.level > 0 then
				hero:SafeCastAbility(searinga, target)
				return true
			end
		end
		hero:Attack(target)
		return true
	end
end

class 'Creep'

function Creep:__init(creepEntity)
	self.creepEntity = creepEntity
	if self.creepEntity.classId == CDOTA_BaseNPC_Creep_Siege then
		self.creepType = "Siege Creep"
		self.attackType = "Siege"
		self.armorType = "Fortified"
	elseif self.creepEntity.classId == CDOTA_BaseNPC_Creep_Lane and (self.creepEntity.armor == 0 or self.creepEntity.armor == 1) then
		self.creepType = "Ranged Creep"
		self.attackType = "Pierce"
		self.armorType = "Unarmored"
	elseif self.creepEntity.classId == CDOTA_BaseNPC_Creep_Lane and (self.creepEntity.armor == 2 or self.creepEntity.armor == 3) then
		self.creepType = "Melee Creep"
		self.attackType = "Normal"
		self.armorType = "Unarmored"
	elseif self.creepEntity.classId == CDOTA_BaseNPC_Venomancer_PlagueWard and self.creepEntity.armor == 0 then
		self.creepType = "Plague Ward"
		self.attackType = "Pierce"
		self.armorType = "Unarmored"
	elseif self.creepEntity.classId == CDOTA_BaseNPC_Tower then
		self.creepType = "Tower"
		self.attackType = "Siege"
		self.armorType = "Fortified"
	elseif self.creepEntity.classId == CDOTA_BaseNPC_Hero then
		self.creepType = "Hero"
		self.attackType = "Hero"
		self.armorType = "Hero"
	elseif self.creepEntity.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit then
		self.creepType = "Forged Spirit"
		self.attackType = "Chaos"
		self.armorType = "Unarmored"
	end
	self.nextAttackTicks = {}
end

function Creep:GetTimeToHealth(health)
	numItems = 0
	for k,v in pairs(self.nextAttackTicks) do
		numItems = numItems + 1
	end
	if numItems > 0 then
		local sortedTable = { }
		for k, v in pairs(self.nextAttackTicks) do table.insert(sortedTable, v) end
		table.sort(sortedTable, function(a,b) return a[2] < b[2] end)		
		local totalDamage = 0
		for _, nextAttackTickTable in ipairs(sortedTable) do					
			if nextAttackTickTable[1].creepEntity.alive and self.creepEntity.alive and client.gameTime < nextAttackTickTable[2] then
				totalDamage = totalDamage + (math.floor((nextAttackTickTable[1].creepEntity.dmgMin + nextAttackTickTable[1].creepEntity.dmgBonus) * Lasthit.armorTypeModifiers[nextAttackTickTable[1].attackType][self.armorType] * (1 - self.creepEntity.dmgResist)))						
				if (self.creepEntity.health - totalDamage) <= health then	
					return nextAttackTickTable[2]
				end
			end
		end 
	end
	return nil
end

function Creep:Update()
	self:MapDamageSources()
	for k, nextAttackTickTable in pairs(self.nextAttackTicks) do
		if client.gameTime > nextAttackTickTable[3] or not nextAttackTickTable[1].creepEntity.alive or not nextAttackTickTable[5].creepEntity.alive or GetDistance2D(nextAttackTickTable[1].creepEntity, nextAttackTickTable[5].creepEntity) > nextAttackTickTable[1].creepEntity.attackRange+50 or (math.max(math.abs(FindAngleR(nextAttackTickTable[1].creepEntity) - math.rad(FindAngleBetween(nextAttackTickTable[1].creepEntity, nextAttackTickTable[5].creepEntity))), 0)) > 0.010093 then
			self.nextAttackTicks[k] = nil
		-- elseif   then
			-- self.nextAttackTicks[k][2] = self.nextAttackTicks[k][2] + ((((nextAttackTickTable[1].projectileSpeed) and (((GetDistance2D(nextAttackTickTable[1].creepEntity.alive, nextAttackTickTable[5].creepEntity)-50)/nextAttackTickTable[1].projectileSpeed))) or 0) + Animations.table[nextAttackTickTable[1].creepEntity.handle].attackTime)
			-- self.nextAttackTicks[k][3] = self.nextAttackTicks[k][3] + ((((nextAttackTickTable[1].projectileSpeed) and (((GetDistance2D(nextAttackTickTable[1].creepEntity.alive, nextAttackTickTable[5].creepEntity)-50)/nextAttackTickTable[1].projectileSpeed))) or 0) + Animations.table[nextAttackTickTable[1].creepEntity.handle].attackTime) + Animations.table[nextAttackTickTable[1].creepEntity.handle].moveTime
		-- elseif client.gameTime > nextAttackTickTable[2] then
			-- self.nextAttackTicks[k][2] = self.nextAttackTicks[k][2] + self.nextAttackTicks[k][4] + ((((nextAttackTickTable[1].projectileSpeed) and (((GetDistance2D(nextAttackTickTable[1].creepEntity.alive, nextAttackTickTable[5].creepEntity)-50)/nextAttackTickTable[1].projectileSpeed))) or 0) + Animations.table[nextAttackTickTable[1].creepEntity.handle].attackTime)
		end
	end
end

function Creep:MapDamageSources()
	for creepHandle, creepClass in pairs(Lasthit.creepTable) do
		if self.creepEntity.team ~= creepClass.creepEntity.team and creepClass.creepEntity.alive and Animations.table[creepClass.creepEntity.handle] then
			local timeToDamageHit = 0
			local nextAttackTick = 0
			for k,z in ipairs(entityList:GetProjectiles({source=creepClass.creepEntity,target=self.creepEntity})) do
				if GetDistance2D(z.position, self.creepEntity) < 127 then
					nextAttackTick = (heroInfo[creepClass.creepEntity.name].attackBackswing / (1 + (self.creepEntity.attackSpeed - 100) / 100)) - (client.latency/1000) - (1/Animations.maxCount)*3  + client.latency/1000
					timeToDamageHit = client.gameTime + ((GetDistance2D(z.position, self.creepEntity)-100)/z.speed) + client.latency/1000
					self.nextAttackTicks[creepClass.creepEntity.handle] = {creepClass, timeToDamageHit, nextAttackTick + client.gameTime, nextAttackTick, self}						
				end
			end
			if GetDistance2D(creepClass.creepEntity.position, self.creepEntity) < creepClass.creepEntity.attackRange+50 and (math.max(math.abs(FindAngleR(creepClass.creepEntity) - math.rad(FindAngleBetween(creepClass.creepEntity, self.creepEntity))), 0)) < 0.010093 and Animations.isAttacking(creepClass.creepEntity) then
				if (not self.nextAttackTicks[creepClass.creepEntity.handle] or client.gameTime > self.nextAttackTicks[creepClass.creepEntity.handle][3]) then
					nextAttackTick = Animations.table[creepClass.creepEntity.handle].moveTime + client.latency/1000
					timeToDamageHit = (Animations.table[creepClass.creepEntity.handle].startTime or client.gameTime) + (((creepClass.projectileSpeed) and (((GetDistance2D(creepClass.creepEntity, self.creepEntity)-100)/creepClass.projectileSpeed))) or 0) + Animations.table[creepClass.creepEntity.handle].attackTime + client.latency/1000
					self.nextAttackTicks[creepClass.creepEntity.handle] = {creepClass, timeToDamageHit, nextAttackTick + (Animations.table[creepClass.creepEntity.handle].startTime or client.gameTime), nextAttackTick, self}		
				end
			end
		end
	end	
end

scriptEngine:RegisterLibEvent(EVENT_FRAME,Lasthit.Tick)
scriptEngine:RegisterLibEvent(EVENT_CLOSE,Lasthit.close)
