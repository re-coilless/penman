INITER = INITER or "PENMAN_IS_REAL"

--[[ BASIC EXAMPLE (there always will be a frame-long delay due to how this system works)
dofile_once( "mods/penman/lib.lua" )

if( my_func_id == nil ) then
	my_func_id = penman_read( "mods/penman/lib.lua" )
elseif( type( my_func_id ) == "number" ) then
	my_func_id = penman_restore( penman_return( my_func_id ))
else
	print( my_func_id )
end
]]

--put all penman funcs into a global table pnm.[func]

penman_r = penman_r or ModTextFileGetContent
penman_w = penman_w or ModTextFileSetContent
function OnWorldPostUpdate()
	dofile_once( "mods/penman/lib.lua" )
	
	if( GameHasFlagRun( INITER )) then
		local world_entity = GameGetWorldStateEntity() or 0
		if( world_entity == 0 ) then
			return
		end
		
		--logo is pen in inkpot

		local storage_request = get_storage( world_entity, "penman_request" )
		local request = ComponentGetValue2( storage_request, "value_string" )
		if( request ~= "" ) then
			local stuff = penman_extract( request )
			for i,event in ipairs( stuff ) do
				if( event[3] ~= nil ) then
					penman_w( event[2], penman_restore( penman_steal( penman_dude( true ), "penman_in_"..event[1])))
				else
					penman_bank( penman_dude( false ), "penman_out_"..event[1], penman_clean( penman_r( event[2])))
				end
			end
			
			-- GlobalsSetValue( "PENMAN_REQUEST_ID", "0" )
			ComponentSetValue2( storage_request, "value_string", "" )
		end
	end
end

function OnPlayerSpawned( hooman )
	if( GameHasFlagRun( INITER )) then
		return
	end
	GameAddFlagRun( INITER )
	
	GlobalsSetValue( "HERMES_IS_REAL", "1" )
	
	local world_entity = GameGetWorldStateEntity()
	EntityAddComponent( world_entity, "VariableStorageComponent", 
	{
		name = "penman_request",
		value_string = "",
	})
	EntityAddComponent( world_entity, "VariableStorageComponent", 
	{
		name = "penman_t2f_count",
		value_int = 0,
	})
	
	EntityAddChild( world_entity, EntityLoad( "mods/penman/dude.xml" ))
	EntityAddChild( world_entity, EntityLoad( "mods/penman/lad.xml" ))
end