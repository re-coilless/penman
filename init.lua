function OnPlayerSpawned( hooman )
	GlobalsSetValue( "HERMES_IS_REAL", "1" )
	
	local world_id = GameGetWorldStateEntity()
	local ctrl_body = EntityLoad( "mods/penman/extra/ctrl_body.xml" )
	EntityAddComponent( ctrl_body, "VariableStorageComponent", 
	{
		name = "request",
		value_string = "&",
	})
	EntityAddChild( world_id, ctrl_body )

	--logo is pen in inkpot
end

penman_w = penman_w or ModTextFileSetContent
function OnWorldPostUpdate()
	dofile_once( "mods/penman/_libman.lua" )

	local world_id = GameGetWorldStateEntity() or 0
	local ctrl_body = pen.get_hooman_child( world_id, "pen_ctrl" )
	local storage_request = pen.get_storage( ctrl_body, "request" )
	if( storage_request == 0 ) then
		return
	end

	local request = ComponentGetValue2( storage_request, "value_string" )
	if( request ~= pen.DIV_1 ) then
		local stuff = pen.magic_parse( request )
		for i,v in ipairs( stuff ) do
			local storage_file = pen.get_storage( ctrl_body, v[2])
			penman_w( v[1], string.gsub( ComponentGetValue2( storage_file, "value_string" ), "\\([nt])", { n = "\n", t = "\t", }))
			ComponentSetValue2( storage_file, "name", "free" )
			ComponentSetValue2( storage_file, "value_string", "" )
		end
		ComponentSetValue2( storage_request, "value_string", pen.DIV_1 )
	end
	
	-- if(( pen.balls or 0 ) == 0 ) then
	-- 	pen.lib.text2func( "balls", [[ function()
	-- 		dofile_once( "mods/penman/_penman.lua" )
			
	-- 		for i = 1,2 do
	-- 			pen.chrono( pen.magic_comp, { pen.get_hooman(), "DamageModelComponent", function( comp_id, is_enabled )
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
				
	-- 			pen.chrono( pen.magic_comp, { pen.get_hooman(), "DamageModelComponent", function( comp_id, is_enabled )
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
end