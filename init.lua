function OnPlayerSpawned( hooman )
	GlobalsSetValue( "HERMES_IS_REAL", "1" )
	
	--logo is pen in inkpot
	
	dofile_once( "mods/penman/_penman.lua" )
	-- pen.magic_comp( hooman, "DamageModelComponent", function( comp_id, is_enabled )
	-- 	pen.magic_comp( comp_id, {"damage_multipliers","explosion"}, 5 )
	-- 	print( pen.magic_comp( comp_id, {"damage_multipliers","explosion"}))
	-- end)
end