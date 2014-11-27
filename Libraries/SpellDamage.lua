require("libs.Utils")
--[[
                             ___
                            ( ((
                             ) ))              
  .::. SPELL DAMAGE LIBRARY / /( MADE BY MOONES      
 'M .-;-.-.-.-.-.-.-.-.-.-/| ((:::::::::::::::::::::::::::::::::::::::::::::.._
(O ( ( ( ( ( ( ( ( ( ( ( ( |  ))   -===========VERSION 1.0.0===========-      _.>
 `M `-;-`-`-`-`-`-`-`-`-`-\| ((::::::::::::::::::::::::::::::::::::::::::::::''
  `::'                      \ \(
        Description:         ) ))
        ------------        (_((                           
		 
         - This library stores damage of all spells
		 
        Usage:
        ------
        
         SpellDamage.GetDamage(spell)     - Returns full damage of given spell. 
         SpellDamage.GetTickDamage(spell) - Returns damage of one tick. (Only for spells with damage ticks)
		 
        Changelog:
        ----------
		
]]--

--Tables with all informations we need to determine actual spell damage
local SpellDamage = {}
local SpellDamage.modifiersSpellList = {	
	modifier_alchemist_acid_spray = { npc = true; npcName = "modifier_alchemist_acid_spray_thinker"; spellName = "alchemist_acid_spray"; spellDamage = "damage"; tickInterval = "tick_rate"; startTime = 0; duration = "duration"; };
	modifier_axe_battle_hunger = { spellName = "axe_battle_hunger"; tickInterval = 1; startTime = 1; duration = "duration"; };
	modifier_batrider_firefly = { spellName = "batrider_firefly"; spellDamage = "damage_per_second"; tickInterval = "tick_interval"; startTime = 0.1; duration = "duration"; trackbySpellCD = true; bonusDmgModifier = "modifier_batrider_sticky_napalm"; bonusDmgModifierSpellname = "batrider_sticky_napalm"; bonusDmgModifierDamage = "damage";};
	modifier_brewmaster_fire_permanent_immolation_aura = { spellName = "brewmaster_fire_permanent_immolation"; spellDamage = "damage"; spellOwner = CDOTA_Unit_Brewmaster_PrimalFire; tickInterval = 1; startTime = 1; };
	modifier_broodmother_poison_sting_dps_debuff = { spellName = "broodmother_poison_sting"; spellDamage = "damage_per_second"; tickInterval = 1; startTime = 1; );	
	modifier_cold_feet = { spellName = "ancient_apparition_cold_feet"; spellDamage = "damage"; tickInterval = {0.8,0.8,0.9,0.9}; startTime = 0.8; };
}
