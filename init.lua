function OnPlayerSpawned( hooman )
	GlobalsSetValue( "HERMES_IS_REAL", "1" )
	
	--logo is pen in inkpot
	
	dofile_once( "mods/penman/_penman.lua" )
	-- pen.text2func( "balls", [[
	-- 	function(a,b)
	-- 		return a + b
	-- 	end
	-- ]])
	-- print( pen.balls( 5, 10 ))
	-- print( pen.magic_comp( pen.get_storage( hooman, "ocarina_song", "value_int", 5 ), "value_int" ))
	
	--[[
	pen.chrono( pen.magic_comp, { hooman, "DamageModelComponent", function( comp_id, is_enabled )
		pen.magic_comp( comp_id, {"damage_multipliers","explosion"}, 5 )
		pen.magic_comp( comp_id, {
			hp = 5,
			max_hp = 50,
			mLastDamageFrame = function( old_val )
				print( old_val )
				return 5
			end,
		})
		print( pen.magic_comp( comp_id, "mLastDamageFrame" ))
	end})

	pen.chrono( pen.magic_comp, { hooman, "DamageModelComponent", function( comp_id, is_enabled )
		ComponentObjectSetValue2( comp_id, "damage_multipliers", "explosion", 5 )
		ComponentSetValue2( comp_id, "hp", 5 )
		ComponentSetValue2( comp_id, "max_hp", 50 )
		print( ComponentGetValue2( comp_id, "mLastDamageFrame" ))
		ComponentSetValue2( comp_id, "mLastDamageFrame", 6 )
		print( ComponentGetValue2( comp_id, "mLastDamageFrame" ))
	end})
	]]
end