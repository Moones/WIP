--[[

	-------------------------------------
	    | SkillShot Dodger by Moones |
	-------------------------------------
	========== Version 1.0.0 ============
	 
	Description:
	------------
	
		Auto Dodge of any SkillShot:
			- This script tries to move perpendicular to avid any skillshot.
			
]]--

require("libs.Utils")
require("libs.VectorOp")
require("libs.SkillShot")
require("libs.ScriptConfig")
--ScriptConfig:SetParameters(table): Allows to add multiple parameters with the the form { {p1,dV1,t1}, {p2,dV2,t2}, ... }.
-- config:SetParameter("rattletrap_hookshot", true)
-- config:SetParameter("meepo_earthbind", true)
-- config:SetParameter("weaver_the_swarm", true)
-- config:SetParameter("shredder_chakram", true)
-- config:SetParameter("queenofpain_sonic_wave", true)
-- config:SetParameter("spectre_spectral_dagger", true)
-- config:SetParameter("lina_dragon_slave", true)
-- config:SetParameter("beastmaster_wild_axes", true)
-- config:SetParameter("jakiro_dual_breath", true)
-- config:SetParameter("earthshaker_fissure", true)
-- config:SetParameter("vengefulspirit_wave_of_terror", true)
-- config:SetParameter("slark_pounce", true)
-- config:SetParameter("shredder_timber_chain", true)
-- config:SetParameter("venomancer_venomous_gale", true)
-- config:SetParameter("magnataur_shockwave", true)
-- config:SetParameter("batrider_flamebreak", true)
-- config:SetParameter("invoker_deafening_blast", true)
-- config:SetParameter("invoker_tornado", true)
-- config:SetParameter("invoker_chaos_meteor", true)
-- config:SetParameter("nyx_assassin_impale", true)
-- config:SetParameter("mirana_arrow", true)
-- config:SetParameter("jakiro_ice_path", true)
-- config:SetParameter("earth_spirit_boulder_smash", true)
-- config:SetParameter("magnataur_skewer", true)
-- config:SetParameter("elder_titan_earth_splitter", true)
-- config:SetParameter("jakiro_macropyre", true)
-- config:SetParameter("puck_illusory_orb", true)
-- config:SetParameter("windrunner_powershot", true)
-- config:SetParameter("tusk_ice_shards", true)
-- config:SetParameter("pudge_meat_hook", true)
-- config:SetParameter("death_prophet_carrion_swarm", true)
-- config:SetParameter("lion_impale", true)
-- config:SetParameter("tiny_avalanche", true)
-- config:SetParameter("shadow_demon_shadow_poison", true)
-- config:Load()

local reg = false local start, vec = nil, nil

local SkillShotList = {
	{ 
		spellName = "pudge_meat_hook";
		heroId = CDOTA_Unit_Hero_Pudge;
		distance = "hook_distance";
		radius = "hook_width";
		block = true;
		team = true;
	};	
	{ 
		spellName = "windrunner_powershot";
		heroId = CDOTA_Unit_Hero_Windrunner;
		distance = "arrow_range";
		radius = "arrow_width";
	};	 
	{
		spellName = "mirana_arrow";
		heroId = CDOTA_Unit_Hero_Mirana;
		distance = "arrow_range";
		radius = "arrow_width";
		speed = "arrow_speed";
		block = true;
		team = "ally";
	};
	{
		spellName = "nyx_assassin_impale";
		heroId = CDOTA_Unit_Hero_Nyx_Assassin;
		distance = "length";
		radius = "width";
	};
	{ 
		spellName = "lion_impale";
		heroId = CDOTA_Unit_Hero_Lion;
		distance = "length";
		radius = "width";
	};
	{ 
		spellName = "death_prophet_carrion_swarm";
		heroId = CDOTA_Unit_Hero_DeathProphet;
		distance = "range";
		radius = "end_radius";
	};
	{ 
		spellName = "magnataur_shockwave";
		heroId = CDOTA_Unit_Hero_Magnataur;
		distance = "shock_distance";
		radius = "shock_width";
	};
	{ 
		spellName = "rattletrap_hookshot";
		heroId = CDOTA_Unit_Hero_Rattletrap;
		distance = "tooltip_range";
		radius = "latch_radius";
		block = true;
		team = true;
	};
	{ 
		spellName = "earthshaker_fissure";
		heroId = CDOTA_Unit_Hero_Earthshaker;
		distance = "fissure_range";
		radius = "fissure_radius";
	};
	{ 
		spellName = "queenofpain_sonic_wave";
		heroId = CDOTA_Unit_Hero_QueenOfPain;
		distance = "distance";
		radius = "final_aoe";
	};
	{ 
		spellName = "tusk_ice_shards";
		heroId = CDOTA_Unit_Hero_Tusk;
		distance = 1500;
		radius = "shard_width";
	};
	{ 
		spellName = "puck_illusory_orb";
		heroId = CDOTA_Unit_Hero_Puck;
		distance = "max_distance";
		radius = "radius";
	};
	{ 
		spellName = "lina_dragon_slave";
		heroId = CDOTA_Unit_Hero_Lina;
		distance = "dragon_slave_distance";
		radius = "dragon_slave_width_initial";
	};
	{ 
		spellName = "jakiro_ice_path";
		heroId = CDOTA_Unit_Hero_Jakiro;
		distance = 1100;
		radius = "path_radius";
	};
	{ 
		spellName = "tiny_avalanche";
		heroId = CDOTA_Unit_Hero_Tiny;
		distance = 600;
		radius = "radius";
	};
	{ 
		spellName = "invoker_chaos_meteor";
		heroId = CDOTA_Unit_Hero_Invoker;
		distance = "travel_distance";
		radius = "area_of_effect";
	};
	{ 
		spellName = "invoker_deafening_blast";
		heroId = CDOTA_Unit_Hero_Invoker;
		distance = "travel_distance";
		radius = "radius_end";
	};
	{ 
		spellName = "invoker_tornado";
		heroId = CDOTA_Unit_Hero_Invoker;
		distance = "travel_distance";
		radius = "area_of_effect";
	};
	{ 
		spellName = "shadow_demon_shadow_poison";
		heroId = CDOTA_Unit_Hero_ShadowDemon;
		distance = 1500;
		radius = "radius";
	};
	{ 
		spellName = "magnataur_skewer";
		heroId = CDOTA_Unit_Hero_Magnataur;
		distance = "range";
		radius = "skewer_radius";
	};
	{ 
		spellName = "meepo_earthbind";
		heroId = CDOTA_Unit_Hero_Meepo;
		distance = "tooltip_range";
		radius = "radius";
	};
	{ 
		spellName = "spectre_spectral_dagger";
		heroId = CDOTA_Unit_Hero_Spectre;
		distance = 2000;
		radius = "dagger_radius";
	};
	{ 
		spellName = "shredder_timber_chain";
		heroId = CDOTA_Unit_Hero_Shredder;
		distance = "range";
		radius = "damage_radius";
	};
	{ 
		spellName = "shredder_chakram";
		heroId = CDOTA_Unit_Hero_Shredder;
		distance = 1200;
		radius = "radius";
	};
	{ 
		spellName = "weaver_the_swarm";
		heroId = CDOTA_Unit_Hero_Weaver;
		distance = 3000;
		radius = "spawn_radius";
	};
	{ 
		spellName = "jakiro_dual_breath";
		heroId = CDOTA_Unit_Hero_Jakiro;
		distance = "range";
		radius = "end_radius";
	};
	{ 
		spellName = "venomancer_venomous_gale";
		heroId = CDOTA_Unit_Hero_Venomancer;
		distance = 800;
		radius = "radius";
	};
	{ 
		spellName = "vengefulspirit_wave_of_terror";
		heroId = CDOTA_Unit_Hero_VengefulSpirit;
		distance = 1400;
		radius = "wave_width";
	};
	{ 
		spellName = "jakiro_macropyre";
		heroId = CDOTA_Unit_Hero_Jakiro;
		distance = "cast_range";
		radius = "path_radius";
		agadistance = "cast_range_scepter";	
	};
	{ 
		spellName = "elder_titan_earth_splitter";
		heroId = CDOTA_Unit_Hero_ElderTitan;
		distance = "crack_distance";
		radius = "crack_width";
	};
	{ 
		spellName = "beastmaster_wild_axes";
		heroId = CDOTA_Unit_Hero_Beastmaster;
		distance = "range";
		radius = "spread";
	};
	{ 
		spellName = "slark_pounce";
		heroId = CDOTA_Unit_Hero_Slark;
		distance = "pounce_distance";
		radius = "pounce_radius";
	};
	{ 
		spellName = "earth_spirit_boulder_smash";
		heroId = CDOTA_Unit_Hero_EarthSpirit;
		distance = "rock_distance";
		radius = "radius";
	};
	{ 
		spellName = "earth_spirit_rolling_boulder";
		heroId = CDOTA_Unit_Hero_EarthSpirit;
		distance = "rock_distance";
		radius = "radius";
	};
	{ 
		spellName = "batrider_flamebreak";
		heroId = CDOTA_Unit_Hero_Batrider;
		distance = 1500;
		radius = "explosion_radius";
	};
}
local settings = {}
for z, skillshot in ipairs(SkillShotList) do
	table.insert(settings,{skillshot.spellName,true})
end
local config = ScriptConfig.new()
config:SetParameters(settings)
config:Load()
	
function Main(tick)
	if not PlayingGame() or client.console or not SleepCheck() then return end
	local me = entityList:GetMyHero()
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team=me:GetEnemyTeam(),visible=true,alive=true})	
	--default spell
	for i,v in ipairs(enemies) do
		if not v:IsIllusion() then
			for z, skillshot in ipairs(SkillShotList) do
				if v.classId == skillshot.heroId or v.classId == CDOTA_Unit_Hero_Rubick then
					--print(skillshot.spellName:gsub('"',""))
					-- if config:GetParameter(skillshot.spellName,true) == nil then
						-- print(skillshot.spellName, config:GetParameter(skillshot.spellName,true))
						-- config:SetParameter(skillshot.spellName, true)
					-- end
					-- config:Load()
					if config:GetParameter(skillshot.spellName,true) then
						local spell = v:FindSpell(skillshot.spellName)
						if spell and (spell.abilityPhase or math.ceil(spell.cd) ==  math.ceil(spell:GetCooldown(spell.level))) then
							local radius = spell:GetSpecialData(skillshot.radius)
							local distance
							local spelllevel = spell.level
							if skillshot.spellName == "invoker_chaos_meteor" or skillshot.spellName == "invoker_tornado" then
								spelllevel = v:GetAbility(2).level
							end
							if type(skillshot.distance) == "string" then
								distance = spell:GetSpecialData(skillshot.distance,spelllevel)
							else
								distance = skillshot.distance
							end
							if v:AghanimState() and skillshot.agadistance then
								distance = spell:GetSpecialData(skillshot.agadistance,spelllevel)
							end
							distance = distance + radius
							local team = skillshot.team or nil
							local block = skillshot.block or false
							if GetDistance2D(v,me) < distance then
								if (block and WillHit(v,me,radius,team)) or not block then						
									LineDodge(Vector(v.position.x + distance * math.cos(v.rotR), v.position.y + distance * math.sin(v.rotR), v.position.z), v.position, radius*2.5, me)	
									Sleep(125)
									break
								end
							end
						end
					end
				end
			end
		end
	end
	--other spell
	local cast = entityList:GetEntities({classId=CDOTA_BaseNPC})
	local Arrow = FindArrowHandle(cast,me)
	if Arrow then
		if not start then
			start = Arrow.position
		end
		if Arrow.visibleToEnemy and not vec then
			vec = Arrow.position
			if GetDistance2D(vec,start) < 50 then
				vec = nil
			end
		end
		if start and vec then
			if WillHit(Arrow,me,115,false) and GetDistance2D(Arrow,start) < GetDistance2D(me,start) then
				LineDodge((FindAB(start,vec,GetDistance2D(me,start)*10)), start, 287.5, me)
				Sleep(125)
			end
		end
	elseif start then	
		start,vec,ArrowHandle = nil,nil,nil
	end
end

function Key(msg,code) 
	if client.chat or not PlayingGame() then return end
	if msg == RBUTTON_UP then
		if not SleepCheck() then
			return true
		end
	end
end

function FindArrowHandle(cast,me)
	for i, z in ipairs(cast) do
		if z.team ~= me.team and z.dayVision == 650 then
			return z
		end
	end
	return nil
end

function LineDodge(pos1, pos2, radius, me)
	local calc1 = (math.floor(math.sqrt((pos2.x-me.position.x)^2 + (pos2.y-me.position.y)^2)))
	local calc2 = (math.floor(math.sqrt((pos1.x-me.position.x)^2 + (pos1.y-me.position.y)^2)))
	local calc4 = (math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.y-pos2.y)^2)))
	local calc3, perpendicular, k, x4, z4, dodgex, dodgey
	perpendicular = (math.floor((math.abs((pos2.x-pos1.x)*(pos1.y-me.position.y)-(pos1.x-me.position.x)*(pos2.y-pos1.y)))/(math.sqrt((pos2.x-pos1.x)^2 + (pos2.y-pos1.y)^2))))
	k = ((pos2.y-pos1.y)*(me.position.x-pos1.x) - (pos2.x-pos1.x)*(me.position.y-pos1.y)) / ((pos2.y-pos1.y)^2 + (pos2.x-pos1.x)^2)
	x4 = me.position.x - k * (pos2.y-pos1.y)
	z4 = me.position.y + k * (pos2.x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-me.position.x)^2 + (z4-me.position.y)^2)))
	dodgex = x4 + (radius/calc3)*(me.position.x-x4)
	dodgey = z4 + (radius/calc3)*(me.position.y-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
		me:Move(Vector(dodgex,dodgey,me.position.z))
	end
end

-- function AoeDodge(pos1, pos2, radius, me)
	-- local calc = (math.floor(math.sqrt((pos2.x-me.position.x)^2 + (pos2.y-me.position.y)^2)))
	-- local dodgex, dodgey
	-- dodgex = pos2.x + (radius/calc)*(me.position.x-pos2.x)
	-- dodgey = pos2.y + (radius/calc)*(me.position.y-pos2.y)
	-- if calc < radius then
		-- me:Move(Vector(dodgex,dodgey,me.position.z))
	-- end
-- end

function FindAB(first, second, distance)
	local xAngle = math.deg(math.atan(math.abs(second.x - first.x)/math.abs(second.y - first.y)))
	local retValue = nil
	local retVector = Vector()
	if first.x <= second.x and first.y >= second.y then
			retValue = 270 + xAngle
	elseif first.x >= second.x and first.y >= second.y then
			retValue = (90-xAngle) + 180
	elseif first.x >= second.x and first.y <= second.y then
			retValue = 90+xAngle
	elseif first.x <= second.x and first.y <= second.y then
			retValue = 90 - xAngle
	end
	retVector = Vector(first.x + math.cos(math.rad(retValue))*distance,first.y + math.sin(math.rad(retValue))*distance,0)
	client:GetGroundPosition(retVector)
	retVector.z = retVector.z+100
	return retVector
end

function WillHit(source,v,radius,team)
	if not SkillShot.__GetBlock(source.position,v.position,v,radius,team) then
		return true
	else
		return false
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then 
			script:Disable()
		else			
			reg = true
			start, vec = nil, nil
			script:RegisterEvent(EVENT_TICK, Main)
			script:RegisterEvent(EVENT_KEY, Key)
			script:UnregisterEvent(Load)
		end
	end	
end

function Close()
	reg = true
	start, vec = nil, nil
	if reg then
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK, Load)	
		reg = false
	end
end

script:RegisterEvent(EVENT_TICK, Load)	
script:RegisterEvent(EVENT_CLOSE, Close)
