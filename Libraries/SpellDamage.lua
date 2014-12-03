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

SpellDamage.modifiersSpellList = {	
	modifier_alchemist_acid_spray = { npc = true; npcModifierName = "modifier_alchemist_acid_spray_thinker"; spellName = "alchemist_acid_spray"; spellDamage = "damage"; tickInterval = "tick_rate"; startTime = 0; duration = "duration"; };
	modifier_axe_battle_hunger = { spellName = "axe_battle_hunger"; tickInterval = 1; startTime = 1; duration = "duration"; };
	modifier_batrider_firefly = { spellName = "batrider_firefly"; spellDamage = "damage_per_second"; tickInterval = "tick_interval"; startTime = 0.1; duration = "duration"; trackbySpellCD = true; bonusDmgModifier = "modifier_batrider_sticky_napalm"; bonusDmgModifierSpellname = "batrider_sticky_napalm"; bonusDmgModifierDamage = "damage";};
	modifier_brewmaster_fire_permanent_immolation_aura = { spellName = "brewmaster_fire_permanent_immolation"; spellDamage = "damage"; spellOwner = CDOTA_Unit_Brewmaster_PrimalFire; tickInterval = 1; startTime = 1; };
	modifier_broodmother_poison_sting_dps_debuff = { spellName = "broodmother_poison_sting"; spellDamage = "damage_per_second"; tickInterval = 1; startTime = 1; };	
	modifier_cold_feet = { spellName = "ancient_apparition_cold_feet"; spellDamage = "damage"; tickInterval = {0.8,0.8,0.9,0.9}; startTime = 0.8; };
	modifier_crystal_maiden_frostbite = { spellName = "crystal_maiden_frostbite"; spellDamage = "damage_per_second_tooltip"; tickInterval = 0.5; startTime = 0; duration = "duration"; };
	modifier_cyclone = { spellDamage = 50; startTime = 2.5; };
	--<<ONE DAY IM GONNA FINISH THIS>>
}

SpellDamage.attackModifiersList = {
	antimage_mana_break = { damage = "mana_per_hit"; multiplier = 0.6; };
	venomancer_poison_sting = { tickDamage = "damage"; tickDuration = "duration"; tickInterval = 1; startTime = 0; };
	viper_poison_attack = { tickDamage = "damage"; tickDuration = "duration"; tickInterval = 1; startTime = 1; };
	clinkz_searing_arrows = { damage = "damage_bonus"; };
	enchantress_impetus = { distance_as_damage = "distance_damage_pct"; };
	huskar_burning_spear = { tickDuration = "8"; };
	bounty_hunter_jinada = { multiplier = "crit_multiplier"; cooldown = true; };
	weaver_geminate_attack = { multiplier = 2; cooldown = true; };
	jakiro_liquid_fire = { tickDamage = "damage"; tickInterval = 1; startTime = 0.5; tickDuration = 5; };
	spectre_desolate = { damage = "bonus_damage"; special = true; };
	silencer_glaives_of_wisdom = { IntToDamage = "intellect_damage_pct"; special = true; };
	obsidian_destroyer_arcane_orb = { manaPercentDamage = "mana_pool_damage_pct"; special = true; };
	brewmaster_drunken_brawler = { damageMultiplier = "crit_multiplier"; }
}

--Spells not listed here returns damage from LuaEntityAbility:GetDamage()
SpellDamage.spellList = {
	antimage_mana_void = { damage = "mana_void_damage_per_mana"; };
	axe_battle_hunger = { tickInterval = 1; startTime = 1; tickDuration = "duration"; };
	axe_culling_blade = { damage = "kill_threshold"; damageScepter = "kill_threshold_scepter"; };
	bane_brain_sap = { damage = "fiend_grip_damage"; duration = "fiend_grip_duration"; tickInterval = "fiend_grip_tick_interval"; damageScepter = "fiend_grip_damage_scepter"; durationScepter = "fiend_grip_duration_scepter"; };
	bloodseeker_blood_bath = { damage = "damage"; };
	earthshaker_enchant_totem = { damageMultiplier = "totem_damage_percentage"; };
	earthshaker_echo_slam = { damage = "echo_slam_echo_damage"; range = "echo_slam_echo_range"; };
	juggernaut_blade_fury = { duration = 5; };
	juggernaut_omni_slash = { damage = 200; multiplier = "omni_slash_jumps"; multiplierScepter = "omni_slash_jumps_scepter"; };
	kunkka_tidebringer = { damage = "damage_bonus"; };
	lina_laguna_blade = { damage = "damage"; typeScepter = DAMAGE_TYPE_PURE; };
	lion_finger_of_death = { damage = "damage"; damageScepter = "damage_scepter"; };
	mirana_arrow = { maxDamageRange = "arrow_max_stunrange";  maxBonusDamage = "arrow_bonus_damage"; };
	mirana_starfall = { maxDamageRadius = "starfall_secondary_radius"; };
	morphling_adaptive_strike = { damage = "damage_base"; maxDamage = "damage_max"; minDamage = "damage_min"; };
	puck_dream_coil = { damage = "coil_init_damage_tooltip"; };
	pudge_dismember = { damage = "dismember_damage"; damageScepterMultiplierStrenght = "strength_damage_scepter"; };
	shadow_shaman_ether_shock = { damage = "damage"; };
	shadow_shaman_shackles = { damage = "total_damage"; };
	shadow_shaman_mass_serpent_ward = { damage = "damage_min"; damageScepter = "damage_min_scepter"; multiplier = "ward_count"; };
	razor_plasma_field = { minDamage = "damage_min"; maxDamage = "damage_max"; range = "radius"; };
	skeleton_king_hellfire_blast = { tickDuration = "blast_dot_duration"; tickDamage = "blast_dot_damage"; };
	storm_spirit_static_remnant = { damage = "static_remnant_damage"; };
	sandking_epicenter = { damage = "epicenter_damage"; multiplier = "epicenter_pulses";  multiplierScepter = "epicenter_pulses_scepter"; };
	tiny_toss = { damage = "toss_damage"; };
	zuus_static_field = { damage = "damage_health_pct"; };
	zuus_thundergods_wrath = { damage = "damage"; damageScepter = "damage_scepter"; };
	crystal_maiden_frostbite = { tickDamage = "damage"; tickDuration = "duration"; };
	lich_chain_frost = { damage = "damage"; damageScepter = "damage_scepter"; };
	riki_blink_strike = { damage = "bonus_damage"; };
	riki_backstab = { damage = "damage_multiplier"; };
	enigma_malefice = { damage = "damage"; multiplier = 3; };
	necrolyte_reapers_scythe = { damage = "damage_per_health"; damageScepter = "damage_per_health_scepter"; };
	warlock_shadow_word = { tickDuration = "duration"; tickInterval = "tick_interval"; startTime = 1; };
	beastmaster_primal_roar = { damage = "damage"; };
	queenofpain_shadow_strike = { damage = "strike_damage"; tickDamage = "duration_damage"; tickInterval = 3; startTime = 3; tickDuration = 15; };
	queenofpain_sonic_wave = { damage = "damage"; damageScepter = "damage_scepter"; };
	venomancer_venomous_gale = { damage = "strike_damage"; tickDuration = "duration"; tickDamage = "tick_damage"; tickInterval = "tick_interval"; startTime = 3; };
	venomancer_poison_nova = { tickDamage = "damage"; tickDuration = "duration"; tickDamageScepter = "damage_scepter"; tickDurationScepter = "duration_scepter"; tickInterval = 1; startTime = 0; };
	templar_assassin_meld = { damage = "bonus_damage"; };
	viper_viper_strike = { tickDamage = "damage"; tickDuration = "duration"; tickInterval = 1; startTime = 1; };
	luna_eclipse = { damageSpell = "luna_lucent_beam"; multiplier = "hit_count"; multiplierScepter = "hit_count_scepter"; };
	dazzle_poison_touch = { startTime = "set_time"; tickInterval = 1; tickDuration = 10; };
	rattletrap_battery_assault = { tickDuration = "duration"; tickInterval = "interval"; startTime = 0; };
	rattletrap_hookshot = { damage = "damage"; };
	leshrac_diabolic_edict = { tickDuration = 8; tickInterval = 0.25; startTime = 0; };
	leshrac_pulse_nova = { tickDamage = "damage"; tickDamageScepter = "damage_scepter"; tickInterval = 1; startTime = 0; };
	furion_wrath_of_nature = { damage = "damage"; damageScepter = "damage_scepter"; };
	life_stealer_infest = { damage = "damage"; };
	dark_seer_vacuum = { damage = "damage"; };
	dark_seer_ion_shell = { tickDamage = "damage_per_second"; tickDuration = "duration"; tickInterval = 1; startTime = 0.1; };
	dark_seer_wall_of_replica = { damage = "damage"; };
	omniknight_purification = { damage = "heal"; };
	huskar_life_break = { damage = "health_damage"; damageScepter = "health_damage_scepter"; };
	broodmother_spawn_spiderlings = { damage = "damage"; };
	bounty_hunter_shuriken_toss = { damage = "bonus_damage"; };
	bounty_hunter_wind_walk = { damage = "bonus_damage"; };
	weaver_shukuchi = { damage = "damage"; };
	jakiro_dual_breath = { tickDamage = "burn_damage"; tickDuration = "tooltip_duration"; tickInterval = 0.5; startTime = 0.5; tickDuration = 5; };
	jakiro_ice_path = { damage = "damage"; };
	jakiro_macropyre = { tickDamage = "damage"; tickDuration = "duration"; tickInterval = 1; tickDamageScepter = "damage_scepter"; tickDurationScepter = "duration_scepter"; startTime = 0.5; };
	batrider_flamebreak = { damage = "damage"; };
	batrider_sticky_napalm = { damage = "damage"; };
	chen_test_of_faith = { maxDamage = "damage_max"; minDamage = "damage_min"; };
	spectre_spectral_dagger = { damage = "damage"; };
	doom_bringer_scorched_earth = { tickDamage = "damage_per_second"; tickDuration = "duration";  tickInterval = 1; startTime = 1; };
	doom_bringer_lvl_death = { damage = "damage"; bonusDamage = "lvl_bonus_damage"; bonusMultiplier = "lvl_bonus_multiple"; };
	doom_bringer_doom = { tickDamage = "damage"; tickDuration = "duration"; tickDamageScepter = "damage_scepter"; tickDurationScepter = "duration_scepter"; tickInterval = 1; startTime = 0; };
	ancient_apparition_cold_feet = { tickDamage = "damage"; tickInterval = {0.8,0.8,0.9,0.9}; startTime = 0.8; };
	ancient_apparition_ice_blast = { tickDuration = "frostbite_duration"; tickDamage = "dot_damage"; bonusDamagePercent = "kill_pct"; tickDurationScepter = "frostbite_duration_scepter"; startTime = 1; tickInterval = 1; };
	spirit_breaker_charge_of_darkness = { damageSpell = "spirit_breaker_greater_bash"; damageSpellName = "damage"; };
	spirit_breaker_nether_strike = { damage = "damage"; damageSpell = "spirit_breaker_greater_bash"; damageSpellName = "damage"; };
	gyrocopter_rocket_barrage = { tickInterval = 1; startTime = 0; tickDuration = 3; };
	gyrocopter_homing_missile = { maxDamageRange = "max_distance"; minBonusDamage = "min_damage"; };
	gyrocopter_call_down = { damage = "damage_first"; bonusDamage = "damage_second"; bonusDamageScepter = "damage_second_scepter"; };
	alchemist_unstable_concoction = { minDamage = "min_damage"; maxDamage = "max_damage"; maxTime = "brew_time"; };
	alchemist_unstable_concoction_throw = { minDamage = "min_damage"; maxDamage = "max_damage"; maxTime = "brew_time"; };
	invoker_cold_snap = { damage = "damage_trigger"; bonusDamage = "freeze_damage"; tickInterval = "freeze_cooldown"; tickDuration = "duration"; spellLevel = "invoker_quas"; };
	invoker_tornado = { damage = "base_damage"; bonusDamage = "wex_damage"; spellLevel = "invoker_wex"; };
	invoker_emp = { damage = "mana_burned"; damageMultiplier = "damage_per_mana_pct"; };
	invoker_chaos_meteor = { tickInterval = "damage_interval"; tickDamage = "main_damage"; bonusDamage = "burn_dps"; bonusDamageMultiplier = "burn_duration"; spellLevel = "invoker_exort"; };
	invoker_sun_strike = { damage = "damage"; spellLevel = "invoker_exort"; };
	invoker_forge_spirit = { damage = "spirit_damage"; spellLevel = "invoker_exort"; };
	invoker_ice_wall = { tickDuration = "duration"; tickDamage = "damage_per_second"; tickInterval = 1; startTime = 1; damagespellLevel = "invoker_exort"; durationspellLevel = "invoker_quas"; };
	invoker_deafening_blast = { damage = "damage"; spellDamage = "invoker_exort"; };
	silencer_curse_of_the_silent = { tickDamage = "health_damage"; tickDuration = "tooltip_duration"; tickInterval = 1; startTime = 1; };
	silencer_last_word = { damage = "damage"; };
	silencer_global_silence = { damageScepter = SpellDamage.spellList[silencer_curse_of_the_silent]; }
	obsidian_destroyer_sanity_eclipse = { damageMultiplier = "damage_multiplier"; differenceTreshold = "int_threshold"; damageMultiplierScepter = "damage_multiplier_scepter"; };
	lycan_summon_wolves = { damage = "wolf_damage"; damageMultiplier = 2; };
	brewmaster_thunder_clap = { damage = "damage"; };
	
	--too hard to finish
}
