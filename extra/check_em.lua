dofile_once( "mods/penman/_libman.lua" )

local hooman = pen.get_hooman()
if( hooman == 0 or pen.testing_done ) then
	return
end
pen.testing_done = true

local dmg_comp = EntityGetFirstComponentIncludingDisabled( hooman, "DamageModelComponent" )

--[[

pen.print_table({
    1,
    2,
    7,
    {
        hmm = {"a","b"},
        huh = {"c","d"},
    },
})

]]

local dmg_comp = EntityGetFirstComponentIncludingDisabled( hooman, "DamageModelComponent" )
pen.clone_comp( hooman, dmg_comp, {
    _tags = "balls",
    max_hp = 50,
})
EntityRemoveComponent( hooman, dmg_comp )
pen.magic_comp( hooman, { "DamageModelComponent", "balls" }, function( comp_id, is_enabled )
    print( ComponentGetValue2( comp_id, "max_hp" ))
end)

-- if(( pen.balls or 0 ) == 0 ) then
-- 	pen.lib.text2func( "balls", [[ function()
-- 		dofile_once( "mods/penman/_penman.lua" )
        
-- 		for i = 1,2 do
-- 			pen.chrono( pen.magic_comp, { hooman, "DamageModelComponent", function( comp_id, is_enabled )
-- 				pen.magic_comp( comp_id, {"damage_multipliers","explosion"}, 5 )
-- 				pen.magic_comp( comp_id, {
-- 					hp = 5,
-- 					max_hp = 50,
-- 					mLastDamageFrame = function( old_val )
-- 						print( old_val )
-- 						return 5
-- 					end,
-- 				})
-- 				print( pen.magic_comp( comp_id, "mLastDamageFrame" ))
-- 			end})
            
-- 			pen.chrono( pen.magic_comp, { hooman, "DamageModelComponent", function( comp_id, is_enabled )
-- 				ComponentObjectSetValue2( comp_id, "damage_multipliers", "explosion", 5 )
-- 				ComponentSetValue2( comp_id, "hp", 5 )
-- 				ComponentSetValue2( comp_id, "max_hp", 50 )
-- 				print( ComponentGetValue2( comp_id, "mLastDamageFrame" ))
-- 				ComponentSetValue2( comp_id, "mLastDamageFrame", 6 )
-- 				print( ComponentGetValue2( comp_id, "mLastDamageFrame" ))
-- 			end})
-- 		end
-- 	end ]])
-- 	if( pen.balls ~= nil ) then
-- 		pen.balls()
-- 		pen.balls = 1
-- 	end
-- end